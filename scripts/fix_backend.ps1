<#
.SYNOPSIS
  Comprehensive backend fix script — resolves all remaining schema mismatches,
  creates missing data, and verifies every Flutter API endpoint.
#>

$ErrorActionPreference = "Continue"
$BASE = "http://102.213.180.186:8000"
$HOST_HEADER = @{"Host" = "aura-beauty.erpnext.local"}
$H = $HOST_HEADER + @{"Content-Type" = "application/json"}
$SEED_DIR = "C:\Users\SOFT-WS\Desktop\AURA 1.0\scripts\seed_data"

function Invoke-Frappe { param([string]$Method, [string]$Path, $Body, $Session)
  $params = @{Uri="$BASE$Path";Method=$Method;Headers=$HOST_HEADER}
  if ($Body) { $params.Body = ($Body | ConvertTo-Json -Compress -Depth 10); $params.ContentType = "application/json" }
  if ($Session) { $params.WebSession = $Session }
  try { return Invoke-RestMethod @params -ErrorAction Stop } catch { return $null }
}

# Authenticate
Write-Host "=== Authenticating as Admin ===" -ForegroundColor Cyan
$login = Invoke-WebRequest -Uri "$BASE/api/method/login" -Method Post -Headers $HOST_HEADER -Body "usr=Administrator&pwd=admin" -ContentType "application/x-www-form-urlencoded" -SessionVariable sess
Write-Host "Logged in as Administrator" -ForegroundColor Green

# =====================================================================
# STEP 1: Fix User Profiles — correct subscription_status, create missing
# =====================================================================
Write-Host "`n=== STEP 1: Fix User Profiles ===" -ForegroundColor Cyan

# Get all users (non-admin)
$usersResp = Invoke-Frappe -Method Get -Path "/api/resource/User?fields=%5B%22name%22%5D&limit_page_length=0&filters=%5B%5B%22User%22%2C%22name%22%2C%22not%20like%22%2C%22%25Administrator%22%5D%5D" -Session $sess
$allUsers = if ($usersResp -and $usersResp.data) { $usersResp.data | Where-Object { $_.name -ne "Guest" } | ForEach-Object { $_.name } } else { @() }
Write-Host "Found $($allUsers.Count) users"

# Get existing profiles
$profResp = Invoke-Frappe -Method Get -Path "/api/resource/Beauty%20User%20Profile?fields=%5B%22name%22%2C%22user%22%2C%22subscription_status%22%5D&limit_page_length=100" -Session $sess
$existingProfiles = @{}
if ($profResp -and $profResp.data) { $profResp.data | ForEach-Object { $existingProfiles[$_.user] = $_ } }

# Fix subscription_status mapping
$statusMap = @{"Free"="Free"; "Aura Plus"="Basic"; "Aura Premium"="Premium"}
$validStatuses = @("Free","Basic","Premium","Enterprise")

# Read user data from JSON for reference
$usersData = @{}
try { $data = Get-Content (Join-Path $SEED_DIR "users.json") -Raw | ConvertFrom-Json; $data | ForEach-Object { $usersData[$_.email] = $_ } } catch {}

$profilesCreated = 0
$profilesFixed = 0

foreach ($email in $allUsers) {
  $exists = $existingProfiles.ContainsKey($email)
  $ud = $usersData[$email]
  
  # Determine correct subscription_status
  $rawStatus = if ($ud) { $ud.subscription_status } else { "Free" }
  $correctStatus = if ($statusMap.ContainsKey($rawStatus)) { $statusMap[$rawStatus] } else { "Free" }
  
  if ($exists) {
    # Fix subscription_status if wrong
    $currentStatus = $existingProfiles[$email].subscription_status
    if ($currentStatus -and ($validStatuses -notcontains $currentStatus)) {
      $r = Invoke-Frappe -Method Put -Path "/api/resource/Beauty%20User%20Profile/$([System.Uri]::EscapeDataString($email))" -Body @{subscription_status=$correctStatus} -Session $sess
      if ($r) { $profilesFixed++ }
    }
  } else {
    # Create missing profile
    $fn = if ($ud) { $ud.full_name } else { $email.Split("@")[0] }
    $st = if ($ud) { if ($validStatuses -contains $ud.skin_type) { $ud.skin_type } else { "Combination" } } else { "Combination" }
    $ht = if ($ud) { if (@("Straight","Wavy","Curly","Coily") -contains $ud.hair_type) { $ud.hair_type } else { "Straight" } } else { "Straight" }
    $ss = if ($ud) { if (@("Low","Medium","High") -contains $ud.skin_sensitivity) { $ud.skin_sensitivity } else { "Medium" } } else { "Medium" }
    $gender = if ($ud) { if (@("Female","Male","Non-binary","Prefer not to say") -contains $ud.gender) { $ud.gender } else { "Female" } } else { "Female" }
    $age = if ($ud) { if (@("18-24","25-34","35-44","45-54","55+") -contains $ud.age_range) { $ud.age_range } else { "25-34" } } else { "25-34" }
    $climate = if ($ud) { if (@("Tropical","Dry","Temperate","Continental","Polar") -contains $ud.climate) { $ud.climate } else { "Temperate" } } else { "Temperate" }
    $hairDens = if ($ud) { if (@("Low","Medium","High") -contains $ud.hair_density) { $ud.hair_density } else { "Medium" } } else { "Medium" }

    $body = @{doctype="Beauty User Profile";user=$email;full_name=$fn;skin_type=$st;hair_type=$ht;skin_sensitivity=$ss;subscription_status=$correctStatus;gender=$gender;age_range=$age;climate=$climate;hair_density=$hairDens;country=$([System.Web.HttpUtility]::UrlDecode("United%20States"));stress_level="Moderate";sleep_quality="Good";onboarding_completed=1;skin_score=(Get-Random -Minimum 55 -Maximum 88);hair_score=(Get-Random -Minimum 55 -Maximum 88)}
    $r = Invoke-Frappe -Method Post -Path "/api/resource/Beauty%20User%20Profile" -Body $body -Session $sess
    if ($r -and $r.data) { $profilesCreated++ }
  }
}
Write-Host "Created $profilesCreated new profiles, fixed $profilesFixed existing" -ForegroundColor Green

# =====================================================================
# STEP 2: Create ERPNext Items for Subscription Plans
# =====================================================================
Write-Host "`n=== STEP 2: Subscription Plans ===" -ForegroundColor Cyan

# Create Item Group first
$igBody = @{doctype="Item Group";item_group_name="Products"}
$ig = Invoke-Frappe -Method Post -Path "/api/resource/Item%20Group" -Body $igBody -Session $sess
if ($ig -and $ig.data) { Write-Host "  Created Item Group: Products" -ForegroundColor Gray }

# Create UOM
$uomBody = @{doctype="UOM";uom_name="Nos"}
$uom = Invoke-Frappe -Method Post -Path "/api/resource/UOM" -Body $uomBody -Session $sess
if ($uom -and $uom.data) { Write-Host "  Created UOM: Nos" -ForegroundColor Gray }

# Create Items
$items = @("AURA-Free","AURA-Basic","AURA-Premium","AURA-Plus-Monthly","AURA-Premium-Monthly")
$itemsCreated = 0
foreach ($iname in $items) {
  $existing = Invoke-Frappe -Method Get -Path "/api/resource/Item/$iname" -Session $sess
  if (-not $existing) {
    $body = @{doctype="Item";item_code=$iname;item_name=$iname.Replace("AURA-","Aura ");item_group="Products";stock_uom="Nos";is_stock_item=0}
    $r = Invoke-Frappe -Method Post -Path "/api/resource/Item" -Body $body -Session $sess
    if ($r -and $r.data) { $itemsCreated++; Write-Host "  Created Item: $iname" -ForegroundColor Gray }
  }
}
Write-Host "Created $itemsCreated Items" -ForegroundColor Green

# Create Subscription Plans
$planData = @(
  @{name="Free";item="AURA-Free";price=0;interval="Month";intervalCount=1;priceDet="Fixed Rate";currency="USD"}
  @{name="Basic";item="AURA-Basic";price=9.99;interval="Month";intervalCount=1;priceDet="Fixed Rate";currency="USD"}
  @{name="Premium";item="AURA-Premium";price=19.99;interval="Month";intervalCount=1;priceDet="Fixed Rate";currency="USD"}
)
$plansCreated = 0
foreach ($pd in $planData) {
  $existing = Invoke-Frappe -Method Get -Path "/api/resource/Subscription%20Plan/$($pd.name)" -Session $sess
  if (-not $existing) {
    $body = @{doctype="Subscription Plan";plan_name=$pd.name;currency=$pd.currency;item=$pd.item;price_determination=$pd.priceDet;billing_interval=$pd.interval;billing_interval_count=$pd.intervalCount;cost=$pd.price}
    $r = Invoke-Frappe -Method Post -Path "/api/resource/Subscription%20Plan" -Body $body -Session $sess
    if ($r -and $r.data) { $plansCreated++; Write-Host "  Created Plan: $($pd.name)" -ForegroundColor Gray }
  }
}
Write-Host "Created $plansCreated Subscription Plans" -ForegroundColor Green

# =====================================================================
# STEP 3: Seed User Routines
# =====================================================================
Write-Host "`n=== STEP 3: User Routines ===" -ForegroundColor Cyan

# Get templates
$tplResp = Invoke-Frappe -Method Get -Path "/api/resource/Routine%20Template?fields=%5B%22name%22%5D&limit_page_length=30" -Session $sess
$tplNames = if ($tplResp -and $tplResp.data) { $tplResp.data | ForEach-Object { $_.name } } else { @() }

# Get products for the routine steps
$prodResp = Invoke-Frappe -Method Get -Path "/api/resource/Beauty%20Product?fields=%5B%22name%22%5D&limit_page_length=50" -Session $sess
$prodNames = if ($prodResp -and $prodResp.data) { $prodResp.data | ForEach-Object { $_.name } } else { @() }

# Get users with profiles (take first 30)
$profUsersResp = Invoke-Frappe -Method Get -Path "/api/resource/Beauty%20User%20Profile?fields=%5B%22user%22%5D&limit_page_length=50" -Session $sess
$routineUsers = if ($profUsersResp -and $profUsersResp.data) { $profUsersResp.data | ForEach-Object { $_.user } } else { @() }

$routinesCreated = 0
foreach ($email in $routineUsers) {
  if ($tplNames.Count -eq 0) { break }
  $tplName = $tplNames[(Get-Random -Maximum $tplNames.Count)]
  
  # Get template steps
  $tplResp = Invoke-Frappe -Method Get -Path "/api/resource/Routine%20Template/$([System.Uri]::EscapeDataString($tplName))" -Session $sess
  $stepsCount = if ($tplResp -and $tplResp.data -and $tplResp.data.steps) { $tplResp.data.steps.Count } else { 3 }
  
  $steps = @()
  for ($s = 1; $s -le $stepsCount; $s++) {
    $pn = if ($prodNames.Count -gt 0) { $prodNames[(Get-Random -Maximum $prodNames.Count)] } else { "" }
    $steps += @{step_number=$s;step_name="Step $s";product=$pn;is_completed=if((Get-Random -Maximum 100) -lt 60){1}else{0}}
  }
  
  $body = @{doctype="User Routine";user=$email;routine_template=$tplName;is_active=1;adherence_rate=(Get-Random -Minimum 40 -Maximum 98);steps=$steps}
  $r = Invoke-Frappe -Method Post -Path "/api/resource/User%20Routine" -Body $body -Session $sess
  if ($r -and $r.data) { $routinesCreated++ }
  
  # 2nd routine for some users
  if ((Get-Random -Maximum 100) -lt 40) {
    $tplName2 = $tplNames | Where-Object { $_ -ne $tplName } | Get-Random
    if ($tplName2) {
      $steps2 = @()
      for ($s = 1; $s -le 3; $s++) { $steps2 += @{step_number=$s;step_name="Step $s";product=$prodNames[(Get-Random -Maximum $prodNames.Count)];is_completed=0} }
      $body2 = @{doctype="User Routine";user=$email;routine_template=$tplName2;is_active=1;adherence_rate=(Get-Random -Minimum 30 -Maximum 90);steps=$steps2}
      $r2 = Invoke-Frappe -Method Post -Path "/api/resource/User%20Routine" -Body $body2 -Session $sess
      if ($r2 -and $r2.data) { $routinesCreated++ }
    }
  }
  if ($routinesCreated % 20 -eq 0 -and $routinesCreated -gt 0) { Write-Host "  Created $routinesCreated routines..." -ForegroundColor Gray }
}
Write-Host "Created $routinesCreated User Routines" -ForegroundColor Green

# =====================================================================
# STEP 4: Seed More Community Posts
# =====================================================================
Write-Host "`n=== STEP 4: Community Posts ===" -ForegroundColor Cyan

$postContents = @(
  "Just finished my 30-day skincare routine! My skin has never looked better.",
  "Has anyone tried the new vitamin C serum? Thinking of adding it to my routine.",
  "Struggling with adult acne at 35. Any product recommendations?",
  "Finally found my holy grail moisturizer! My sensitive skin is loving this.",
  "My curly hair journey update: 3 months and the difference is amazing!",
  "What's your go-to sunscreen for oily skin? Need something non-greasy.",
  "Just discovered niacinamide and it's changed my skin texture completely.",
  "Starting my retinol journey tonight! Any tips for beginners?",
  "The power of double cleansing cannot be overstated. So much clearer now.",
  "Beauty tip: Don't forget your neck and chest in your routine!",
  "Can we talk about scalp health? Started using a scalp scrub - amazing!",
  "My nighttime routine takes 15 minutes and it's my favorite self-care moment.",
  "Question: How do you deal with maskne? My chin is breaking out.",
  "Just got my Aura Premium subscription! Excited for exclusive products.",
  "For anyone with KP on arms, try lactic acid body lotion. Game changer!",
  "Dry skin girl here. What's your favorite sleeping mask?",
  "Tracking progress with Aura for 2 weeks. Love seeing the improvements!",
  "My affordable routine that delivers luxury results. Total under $50!",
  "Finally figured out my hair porosity and it transformed my approach.",
  "Hot take: You don't need 10-step routine. Consistency > complexity."
)

$postUsers = $routineUsers | Select-Object -First 20
$postsCreated = 0
$groupResp = Invoke-Frappe -Method Get -Path "/api/resource/Community%20Group?fields=%5B%22name%22%5D&limit_page_length=20" -Session $sess
$groupNames = if ($groupResp -and $groupResp.data) { $groupResp.data | ForEach-Object { $_.name } } else { @() }

foreach ($email in $postUsers) {
  $content = $postContents[(Get-Random -Maximum $postContents.Length)]
  $group = if ($groupNames.Count -gt 0 -and (Get-Random -Maximum 100) -lt 40) { $groupNames[(Get-Random -Maximum $groupNames.Count)] } else { "" }
  $title = if ($content.Length -gt 40) { $content.Substring(0,37) + "..." } else { $content }
  $body = @{doctype="Community Post";title=$title;content=$content;author=$email;group=$group;likes=(Get-Random -Minimum 0 -Maximum 120);tags=""}
  $r = Invoke-Frappe -Method Post -Path "/api/resource/Community%20Post" -Body $body -Session $sess
  if ($r -and $r.data) { $postsCreated++ }
}
Write-Host "Created $postsCreated Community Posts" -ForegroundColor Green

# =====================================================================
# STEP 5: Seed AI Conversations
# =====================================================================
Write-Host "`n=== STEP 5: AI Conversations ===" -ForegroundColor Cyan

$aiQuestions = @(
  @{m="What's a good basic skincare routine?";r="A basic routine has 3 steps: cleanser, moisturizer, and SPF.";c="Routine"},
  @{m="My skin is so oily. What can I do?";r="Use niacinamide, salicylic acid, and gel-based moisturizers.";c="Skin Concern"},
  @{m="How do I fade dark spots?";r="Vitamin C, niacinamide, and daily SPF are key.";c="Skin Concern"},
  @{m="Is retinol safe every night?";r="Start slow: once a week, gradually increase to every other night.";c="Product"},
  @{m="What ingredients shouldn't I mix?";r="Don't mix vitamin C with benzoyl peroxide or retinol with AHAs.";c="Product"},
  @{m="How can I improve hair growth?";r="Scalp serums, protein-rich diet, and regular trims help.";c="Hair Concern"},
  @{m="I have dandruff that won't go away";r="Rotate ketoconazole, zinc pyrithione, and salicylic acid shampoos.";c="Hair Concern"},
  @{m="Best way to treat acne scars?";r="Vitamin C, retinoids, and professional treatments like microneedling.";c="Skin Concern"},
  @{m="Recommend a routine for dry skin";r="Cream cleanser, hyaluronic acid, ceramide moisturizer, facial oil.";c="Routine"},
  @{m="What should I eat for better skin?";r="Fatty fish, avocados, berries, and green tea are great for skin.";c="General"}
)
$aiCount = 0
$aiUsers = $routineUsers | Select-Object -First 20
foreach ($email in $aiUsers) {
  $numConvs = Get-Random -Minimum 1 -Maximum 4
  for ($c = 0; $c -lt $numConvs; $c++) {
    $qa = $aiQuestions[(Get-Random -Maximum $aiQuestions.Length)]
    $ts = (Get-Date).AddDays(-(Get-Random -Minimum 0 -Maximum 14)).ToString("yyyy-MM-dd HH:mm:ss.ffffff")
    $sents = @("Positive","Neutral","Negative","Frustrated","Curious")
    $body = @{doctype="AI Conversation";user=$email;timestamp=$ts;message=$qa.m;response=$qa.r;context=$qa.c;sentiment=$sents[(Get-Random -Maximum $sents.Length)]}
    $r = Invoke-Frappe -Method Post -Path "/api/resource/AI%20Conversation" -Body $body -Session $sess
    if ($r -and $r.data) { $aiCount++ }
  }
}
Write-Host "Created $aiCount AI Conversations" -ForegroundColor Green

# =====================================================================
# STEP 6: Seed More Progress & Diary Entries
# =====================================================================
Write-Host "`n=== STEP 6: Progress Entries ===" -ForegroundColor Cyan

$progUsers = $routineUsers | Select-Object -First 30
$progCount = 0
$diaryCount = 0
foreach ($email in $progUsers) {
  $num = Get-Random -Minimum 3 -Maximum 10
  for ($d = 0; $d -lt $num; $d++) {
    $dt = (Get-Date).AddDays(-$d).ToString("yyyy-MM-dd")
    $moods = @("Great","Good","Neutral","Low","Stressed")
    $sleeps = @("Poor","Fair","Good","Excellent")
    
    $entryTypes = @("Diary","Assessment","Routine","Custom")
    $peBody = @{doctype="Progress Entry";user=$email;entry_date=$dt;entry_type=$entryTypes[(Get-Random -Maximum $entryTypes.Length)];value=(Get-Random -Minimum 3 -Maximum 10);notes="Auto-tracked progress entry";skin_score=(Get-Random -Minimum 55 -Maximum 95);hair_score=(Get-Random -Minimum 50 -Maximum 90);mood=$moods[(Get-Random -Maximum $moods.Length)];sleep_quality=$sleeps[(Get-Random -Maximum $sleeps.Length)]}
    $r = Invoke-Frappe -Method Post -Path "/api/resource/Progress%20Entry" -Body $peBody -Session $sess
    if ($r -and $r.data) { $progCount++ }
  }
}
Write-Host "Created $progCount Progress Entries" -ForegroundColor Green

# =====================================================================
# STEP 7: Seed Skin Assessments  
# =====================================================================
Write-Host "`n=== STEP 7: Skin Assessments ===" -ForegroundColor Cyan

# Get Concern Tags for child tables
$ctResp = Invoke-Frappe -Method Get -Path "/api/resource/Concern%20Tag?fields=%5B%22name%22%5D&limit_page_length=30" -Session $sess
$ctNames = if ($ctResp -and $ctResp.data) { $ctResp.data | ForEach-Object { $_.name } } else { @() }
$assessUsers = $routineUsers | Select-Object -First 25
$assessCount = 0
$skinTypes = @("Oily","Dry","Combination","Normal")
$sensLevels = @("Low","Medium","High")
foreach ($email in $assessUsers) {
  $concernCount = Get-Random -Minimum 1 -Maximum 4
  $selectedConcerns = if ($ctNames.Count -gt 0) { $ctNames | Get-Random -Count ([Math]::Min($concernCount, $ctNames.Count)) | ForEach-Object { @{concern=$_} } } else { @() }
  $body = @{doctype="Skin Assessment";user=$email;assessment_date=(Get-Date).AddDays(-(Get-Random -Minimum 0 -Maximum 30)).ToString("yyyy-MM-dd HH:mm:ss.ffffff");skin_type=$skinTypes[(Get-Random -Maximum $skinTypes.Length)];skin_sensitivity=$sensLevels[(Get-Random -Maximum $sensLevels.Length)];concerns=$selectedConcerns;overall_score=(Get-Random -Minimum 40 -Maximum 96)}
  $r = Invoke-Frappe -Method Post -Path "/api/resource/Skin%20Assessment" -Body $body -Session $sess
  if ($r -and $r.data) { $assessCount++ }
}
Write-Host "Created $assessCount Skin Assessments" -ForegroundColor Green

# =====================================================================
# STEP 8: Recommendation Results
# =====================================================================
Write-Host "`n=== STEP 8: Recommendation Results ===" -ForegroundColor Cyan

# Check child table for recommendation products
$recProdResp = Invoke-RestMethod -Uri "$BASE/api/resource/DocType/Recommendation%20Result" -Method Get -Headers $H -WebSession $sess -ErrorAction SilentlyContinue
$recProdDt = if ($recProdResp -and $recProdResp.data) { ($recProdResp.data.fields | Where-Object { $_.fieldname -eq "products" }).options } else { "Recommended Product" }

$recUsers = $routineUsers | Select-Object -First 20
$recCount = 0
foreach ($email in $recUsers) {
  $numRecs = Get-Random -Minimum 1 -Maximum 4
  $recProducts = @()
  for ($r = 0; $r -lt $numRecs -and $r -lt $prodNames.Count; $r++) {
    $pn = $prodNames[(Get-Random -Maximum $prodNames.Count)]
    $recProducts += @{doctype=$recProdDt;product=$pn;relevance_score=[math]::Round((Get-Random -Minimum 60 -Maximum 99)/100,2);reason="Recommended based on your profile";routine_step=@("Cleanser","Serum","Moisturizer","Treatment")[(Get-Random -Maximum 4)]}
  }
  if ($recProducts.Count -gt 0) {
    $body = @{doctype="Recommendation Result";user=$email;confidence_score=[math]::Round((Get-Random -Minimum 60 -Maximum 95)/100,2);reasoning="Generated based on skin profile analysis";generated_date=(Get-Date).AddDays(-(Get-Random -Minimum 0 -Maximum 7)).ToString("yyyy-MM-dd HH:mm:ss.ffffff");expires_date=(Get-Date).AddDays(30).ToString("yyyy-MM-dd");products=$recProducts}
    $r = Invoke-Frappe -Method Post -Path "/api/resource/Recommendation%20Result" -Body $body -Session $sess
    if ($r -and $r.data) { $recCount++ }
  }
}
Write-Host "Created $recCount Recommendation Results" -ForegroundColor Green

# =====================================================================
# STEP 9: Seed User Subscriptions
# =====================================================================
Write-Host "`n=== STEP 9: User Subscriptions ===" -ForegroundColor Cyan

$subUsers = $routineUsers | Select-Object -First 40
$subCount = 0
foreach ($email in $subUsers) {
  $planNames = @("Free","Free","Free","Basic","Premium")
  $planName = $planNames[(Get-Random -Maximum $planNames.Length)]
  $startDate = (Get-Date).AddDays(-(Get-Random -Minimum 0 -Maximum 90)).ToString("yyyy-MM-dd")
  $endDate = (Get-Date).AddDays(30).ToString("yyyy-MM-dd")
  $body = @{doctype="User Subscription";user=$email;plan=$planName;start_date=$startDate;end_date=$endDate;is_active=1;auto_renew=1;subscription_type="Monthly"}
  $r = Invoke-Frappe -Method Post -Path "/api/resource/User%20Subscription" -Body $body -Session $sess
  if ($r -and $r.data) { $subCount++ }
}
Write-Host "Created $subCount User Subscriptions" -ForegroundColor Green

# =====================================================================
# STEP 10: Seed User Badges  
# =====================================================================
Write-Host "`n=== STEP 10: User Badges ===" -ForegroundColor Cyan

$badgeResp = Invoke-Frappe -Method Get -Path "/api/resource/Achievement%20Badge?fields=%5B%22name%22%5D&limit_page_length=30" -Session $sess
$badgeNames = if ($badgeResp -and $badgeResp.data) { $badgeResp.data | ForEach-Object { $_.name } } else { @() }
$badgeUsers = $routineUsers | Select-Object -First 30
$badgeCount = 0
foreach ($email in $badgeUsers) {
  if ($badgeNames.Count -eq 0) { break }
  $num = Get-Random -Minimum 1 -Maximum 5
  $selected = $badgeNames | Get-Random -Count $num
  foreach ($bn in $selected) {
    $body = @{doctype="User Badge";user=$email;badge=$bn;is_earned=1;progress=100;earned_date=(Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("yyyy-MM-dd HH:mm:ss")}
    $r = Invoke-Frappe -Method Post -Path "/api/resource/User%20Badge" -Body $body -Session $sess
    if ($r -and $r.data) { $badgeCount++ }
  }
}
Write-Host "Created $badgeCount User Badges" -ForegroundColor Green

# =====================================================================
# FINAL VERIFICATION
# =====================================================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  FINAL VERIFICATION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Verify as admin (public endpoints + resource counts)
Write-Host "`n--- Admin Verification (resource counts) ---" -ForegroundColor Yellow
$countChecks = @("User","Beauty User Profile","Beauty Product","Product Ingredient","Routine Template","Subscription Plan","User Routine","Community Post","AI Conversation","Progress Entry","Skin Assessment","Recommendation Result","User Subscription","Achievement Badge","User Badge","Ingredient Conflict","Marketplace Partner","Community Group","Challenge")
foreach ($dt in $countChecks) {
  $resp = Invoke-Frappe -Method Get -Path "/api/resource/$([System.Uri]::EscapeDataString($dt))?fields=%5B%22name%22%5D&limit_page_length=0" -Session $sess
  $count = if ($resp -and $resp.data) { $resp.data.Count } else { 0 }
  Write-Host "  $dt : $count" -ForegroundColor $(if ($count -gt 0){"Green"}else{"Red"})
}

# API endpoint verification (as user)
Write-Host "`n--- API Endpoint Verification (as user) ---" -ForegroundColor Yellow
# Log in as a user who has a profile
$userLogin = Invoke-WebRequest -Uri "$BASE/api/method/login" -Method Post -Headers $HOST_HEADER -Body "usr=aiden.turner@example.com&pwd=Demo@2026!" -ContentType "application/x-www-form-urlencoded" -SessionVariable userSess

$apiTests = @(
  @{N="get_profile";P="/api/method/aura.api.profile.get_profile"}
  @{N="get_products";P="/api/method/aura.api.products.get_products"}
  @{N="get_plans";P="/api/method/aura.api.subscriptions.get_plans"}
  @{N="get_feed";P="/api/method/aura.api.community.get_feed"}
  @{N="get_groups";P="/api/method/aura.api.community.get_groups"}
  @{N="get_routines";P="/api/method/aura.api.routines.get_routines"}
  @{N="get_templates";P="/api/method/aura.api.routines.get_templates"}
  @{N="get_progress";P="/api/method/aura.api.progress.get_progress"}
  @{N="get_my_badges";P="/api/method/aura.api.badges.get_my_badges"}
  @{N="get_all_badges";P="/api/method/aura.api.badges.get_all_badges"}
  @{N="get_ingredients";P="/api/method/aura.api.ingredients.get_ingredients"}
  @{N="get_conflicts";P="/api/method/aura.api.ingredients.get_conflicts"}
  @{N="analyze_needs";P="/api/method/aura.api.need_analyzer.analyze_needs"}
  @{N="get_assessment_history";P="/api/method/aura.api.assessments.get_assessment_history"}
  @{N="get_recommendations";P="/api/method/aura.api.recommendations.get_recommendations"}
  @{N="get_chat_history";P="/api/method/aura.api.ai_coach.get_history"}
)
$pass = 0; $fail = 0
foreach ($t in $apiTests) {
  try {
    $resp = Invoke-RestMethod -Uri "$BASE$($t.P)" -Headers $HOST_HEADER -WebSession $userSess
    $msg = $resp.message
    if ($msg -is [System.Array]) {
      $c = $msg.Count
      Write-Host "  $($t.N): $c items" -ForegroundColor $(if ($c -gt 0){"Green"}else{"Yellow"})
      if ($c -gt 0) { $pass++ } else { $fail++ }
    } elseif ($msg) {
      Write-Host "  $($t.N): OK" -ForegroundColor Green; $pass++
    } else {
      Write-Host "  $($t.N): null" -ForegroundColor Red; $fail++
    }
  } catch {
    Write-Host "  $($t.N): ERROR" -ForegroundColor Red; $fail++
  }
}
Write-Host "API Verification: $pass passed, $fail failed" -ForegroundColor Cyan

# =====================================================================
# SUMMARY
# =====================================================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  BACKEND FIX COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Profiles created/fixed: $profilesCreated / $profilesFixed"
Write-Host "Items created: $itemsCreated"
Write-Host "Subscription Plans created: $plansCreated"
Write-Host "User Routines created: $routinesCreated"
Write-Host "Community Posts created: $postsCreated"
Write-Host "AI Conversations created: $aiCount"
Write-Host "Progress Entries created: $progCount"
Write-Host "Skin Assessments created: $assessCount"
Write-Host "Recommendation Results created: $recCount"
Write-Host "User Subscriptions created: $subCount"
Write-Host "User Badges created: $badgeCount"
Write-Host "`nDone!" -ForegroundColor Cyan
