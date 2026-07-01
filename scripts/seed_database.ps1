<#
.SYNOPSIS
  Comprehensive AURA database seeding script - populates all DocTypes with realistic demo data.
.DESCRIPTION
  Seeds 30 Concern Tags, 150+ Product Ingredients, 5 Subscription Plans, 10 Community Groups,
  20 Achievement Badges, 10 Routine Templates, 5 Marketplace Partners, 100 Beauty Products,
  100 Users with Profiles, 25 Ingredient Conflicts, then generates assessments, routines,
  posts, comments, progress, badges, AI conversations, and more.
#>

$ErrorActionPreference = "Continue"
$BASE = "http://102.213.180.186:8000"
$HOST_HEADER = @{"Host" = "aura-beauty.erpnext.local"}
$CONTENT_JSON = @{"Content-Type" = "application/json"}
$HEADERS = $HOST_HEADER + $CONTENT_JSON
$SEED_DIR = "C:\Users\SOFT-WS\Desktop\AURA 1.0\scripts\seed_data"

$STATS = @{}
$CREATED = @{}
$FAILED = @()
$PASS = 0
$FAIL_COUNT = 0

function Write-Step { param([string]$Msg) Write-Host "`n========================================" -ForegroundColor Cyan; Write-Host "  $Msg" -ForegroundColor Cyan; Write-Host "========================================" -ForegroundColor Cyan }

function Write-Result { param([string]$Name, [bool]$Passed, [string]$Detail)
  if ($Passed) { $PASS++; Write-Host "  [PASS] $Name" -ForegroundColor Green }
  else { $FAIL_COUNT++; Write-Host "  [FAIL] $Name`: $Detail" -ForegroundColor Red; $script:FAILED += "$Name`: $Detail" }
}

function Invoke-Api {
  param([string]$Method, [string]$Path, $Body, $Session)
  $params = @{ Uri = "$BASE$Path"; Method = $Method; Headers = $HEADERS }
  if ($Body) { $params.Body = ($Body | ConvertTo-Json -Compress -Depth 10) }
  if ($Session) { $params.WebSession = $Session }
  try { return Invoke-RestMethod @params -ErrorAction Stop } catch { return $null }
}

function Doc-Exists {
  param([string]$DocType, [string]$Name, $Session)
  $resp = Invoke-Api -Method Get -Path "/api/resource/$DocType/$([System.Uri]::EscapeDataString($Name))" -Session $Session
  return ($resp -and $resp.data)
}

function Create-Doc-Unless-Exists {
  param([string]$DocType, $Body, $Session)
  $name = $Body.name
  if (-not $name) { $name = $Body.concern_name }
  if (-not $name) { $name = $Body.ingredient_name }
  if (-not $name) { $name = $Body.email }
  if (-not $name) { $name = $Body.plan_name }
  if (-not $name) { $name = $Body.group_name }
  if (-not $name) { $name = $Body.badge_name }
  if (-not $name) { $name = $Body.template_name }
  if (-not $name) { $name = $Body.partner_name }
  if (-not $name) { $name = $Body.tag_name }
  if ($name -and (Doc-Exists -DocType $DocType -Name $name -Session $Session)) { return $null }
  return Invoke-Api -Method Post -Path "/api/resource/$DocType" -Body $Body -Session $Session
}

function Seed-File {
  param([string]$FilePath, [string]$DocType, [string]$Label)
  if (-not (Test-Path $FilePath)) { Write-Result -Name $Label -Passed $false -Detail "File not found"; return @() }
  $items = Get-Content $FilePath -Raw | ConvertFrom-Json
  $created = @()
  $count = 0
  foreach ($item in $items) {
    $resp = Create-Doc-Unless-Exists -DocType $DocType -Body $item -Session $session
    if ($resp -and $resp.data) { $count++; $created += $resp.data.name }
  }
  $script:STATS[$Label] = $count
  Write-Result -Name "$Label ($count)" -Passed $true -Detail "$count created"
  return $created
}

# ====== PHASE 0: AUTH ======
Write-Step "PHASE 0: Authentication"
try {
  $login = Invoke-WebRequest -Uri "$BASE/api/method/login" -Method Post `
    -Headers $HOST_HEADER -Body "usr=Administrator&pwd=admin" `
    -ContentType "application/x-www-form-urlencoded" `
    -SessionVariable session
  Write-Host "  Logged in as Administrator" -ForegroundColor Green
} catch {
  Write-Host "  Admin login failed: $($_.Exception.Message)" -ForegroundColor Red
  exit 1
}

# ====== PHASE 1: REFERENCE DATA ======
Write-Step "PHASE 1: Reference Data"
$createdConcerns  = Seed-File -FilePath (Join-Path $SEED_DIR "concern_tags.json")        -DocType "Concern Tag"        -Label "Concern Tags"
$createdIngredients = Seed-File -FilePath (Join-Path $SEED_DIR "ingredients.json")        -DocType "Product Ingredient" -Label "Product Ingredients"
$createdPlans      = Seed-File -FilePath (Join-Path $SEED_DIR "subscription_plans.json") -DocType "Subscription Plan"  -Label "Subscription Plans"
$createdGroups     = Seed-File -FilePath (Join-Path $SEED_DIR "community_groups.json")   -DocType "Community Group"    -Label "Community Groups"
$createdBadges     = Seed-File -FilePath (Join-Path $SEED_DIR "badges.json")              -DocType "Achievement Badge"  -Label "Achievement Badges"
$createdTemplates  = Seed-File -FilePath (Join-Path $SEED_DIR "routine_templates.json") -DocType "Routine Template"   -Label "Routine Templates"
$createdPartners   = Seed-File -FilePath (Join-Path $SEED_DIR "partners.json")            -DocType "Marketplace Partner" -Label "Marketplace Partners"

$script:CREATED["concerns"] = $createdConcerns
$script:CREATED["ingredients"] = $createdIngredients
$script:CREATED["plans"] = $createdPlans
$script:CREATED["groups"] = $createdGroups
$script:CREATED["badges"] = $createdBadges
$script:CREATED["templates"] = $createdTemplates
$script:CREATED["partners"] = $createdPartners

# ====== PHASE 2: INGREDIENT CONFLICTS ======
Write-Step "PHASE 2: Ingredient Conflicts"
$createdConflicts = Seed-File -FilePath (Join-Path $SEED_DIR "ingredient_conflicts.json") -DocType "Ingredient Conflict" -Label "Ingredient Conflicts"
$script:CREATED["conflicts"] = $createdConflicts

# ====== PHASE 3: PRODUCTS ======
Write-Step "PHASE 3: Beauty Products"
$createdProducts = Seed-File -FilePath (Join-Path $SEED_DIR "products.json") -DocType "Beauty Product" -Label "Beauty Products"
$script:CREATED["products"] = $createdProducts

# ====== PHASE 4: USERS ======
Write-Step "PHASE 4: Demo Users"
$usersData = Get-Content (Join-Path $SEED_DIR "users.json") -Raw | ConvertFrom-Json
$createdUsers = @()
$createdProfiles = @()
$userIndex = 0

foreach ($u in $usersData) {
  $userIndex++
  $email = $u.email
  $fullName = $u.full_name
  $nameParts = $fullName.Split(" ", 2)
  $firstName = $nameParts[0]
  $lastName = if ($nameParts.Count -gt 1) { $nameParts[1] } else { "User" }

  $userExists = Doc-Exists -DocType "User" -Name $email -Session $session
  if (-not $userExists) {
    $userBody = @{doctype = "User"; email = $email; first_name = $firstName; last_name = $lastName; enabled = 1; send_welcome_email = 0; user_type = "Website User"}
    $userResp = Invoke-Api -Method Post -Path "/api/resource/User" -Body $userBody -Session $session
    if ($userResp -and $userResp.data) {
      $createdUsers += $email
      Invoke-Api -Method Post -Path "/api/method/frappe.core.doctype.user.user.update_password" -Body @{new_password = "Demo@2026!"; user = $email} -Session $session | Out-Null
    }
  } else { $createdUsers += $email }

  $profileExists = Doc-Exists -DocType "Beauty User Profile" -Name $email -Session $session
  if (-not $profileExists) {
    $skinScore = [math]::Round((Get-Random -Minimum 55 -Maximum 88), 0)
    if ($u.skin_sensitivity -eq "High") { $skinScore -= 10 }
    if ($u.sleep_quality -in @("Good","Excellent")) { $skinScore += 5 }
    $hairScore = [math]::Round((Get-Random -Minimum 55 -Maximum 88), 0)
    if ($u.hair_density -eq "Low") { $hairScore -= 5 }
    if ($u.stress_level -eq "Low") { $hairScore += 5 }
    $profileBody = @{doctype = "Beauty User Profile"; user = $email; full_name = $fullName; skin_type = $u.skin_type; hair_type = $u.hair_type; skin_sensitivity = $u.skin_sensitivity; gender = $u.gender; age_range = $u.age_range; country = $u.country; climate = $u.climate; stress_level = $u.stress_level; sleep_quality = $u.sleep_quality; subscription_status = $u.subscription_status; onboarding_completed = 1; hair_density = $u.hair_density; skin_score = $skinScore; hair_score = $hairScore}
    $profileResp = Invoke-Api -Method Post -Path "/api/resource/Beauty User Profile" -Body $profileBody -Session $session
    if ($profileResp -and $profileResp.data) { $createdProfiles += $email }
  } else { $createdProfiles += $email }

  if ($userIndex % 20 -eq 0) { Write-Host "  Processed $userIndex users..." -ForegroundColor Gray }
}

$script:STATS["Users"] = $createdUsers.Count
$script:STATS["Beauty User Profiles"] = $createdProfiles.Count
Write-Result -Name "Users ($($createdUsers.Count))" -Passed ($createdUsers.Count -gt 0) -Detail "$($createdUsers.Count) users created"
Write-Result -Name "Beauty User Profiles ($($createdProfiles.Count))" -Passed ($createdProfiles.Count -gt 0) -Detail "$($createdProfiles.Count) profiles created"
$script:CREATED["users"] = $createdUsers

# ====== PHASE 5: USER SUBSCRIPTIONS ======
Write-Step "PHASE 5: User Subscriptions"
$demoUsers = $createdUsers | Select-Object -First 80
$subCount = 0
foreach ($email in $demoUsers) {
  $planNames = @("Free", "Free", "Free", "Aura Plus Monthly", "Aura Premium Monthly")
  $planName = $planNames[(Get-Random -Maximum $planNames.Length)]
  $subBody = @{doctype = "User Subscription"; user = $email; plan = $planName; is_active = 1; auto_renew = 1; subscription_type = "Monthly"}
  $resp = Create-Doc-Unless-Exists -DocType "User Subscription" -Body $subBody -Session $session
  if ($resp -and $resp.data) { $subCount++ }
}
$script:STATS["User Subscriptions"] = $subCount
Write-Result -Name "User Subscriptions ($subCount)" -Passed $true -Detail "$subCount subscriptions created"

# ====== PHASE 6: ASSESSMENTS ======
Write-Step "PHASE 6: User Assessments"
$assessCount = 0
$assessUsers = $createdUsers | Select-Object -First 60
foreach ($email in $assessUsers) {
  $skinTypes = @("Oily","Dry","Combination","Normal")
  $sensLevels = @("Low","Medium","High")
  $goals = @(@{goal = "Hydration"}, @{goal = "Anti-aging"}, @{goal = "Acne Control"}, @{goal = "Brightening"}, @{goal = "Oil Control"})
  $selectedGoals = $goals | Get-Random -Count (Get-Random -Minimum 1 -Maximum 3)

  $saBody = @{doctype = "Skin Assessment"; user = $email; skin_type = $skinTypes[(Get-Random -Maximum $skinTypes.Length)]; sensitivity = $sensLevels[(Get-Random -Maximum $sensLevels.Length)]; acne_presence = @("None","Mild","Moderate")[(Get-Random -Maximum 3)]; pigmentation = @("None","Low","Medium")[(Get-Random -Maximum 3)]; hydration_level = (Get-Random -Minimum 30 -Maximum 90); overall_score = (Get-Random -Minimum 50 -Maximum 95); main_goals = $selectedGoals}
  $resp = Invoke-Api -Method Post -Path "/api/resource/Skin Assessment" -Body $saBody -Session $session
  if ($resp -and $resp.data) { $assessCount++ }

  if ((Get-Random -Maximum 100) -lt 67) {
    $hairTypes = @("Straight","Wavy","Curly","Coily")
    $scalpConds = @("Normal","Dry","Oily","Sensitive","Dandruff")
    $haBody = @{doctype = "Hair Assessment"; user = $email; hair_type = $hairTypes[(Get-Random -Maximum $hairTypes.Length)]; scalp_condition = $scalpConds[(Get-Random -Maximum $scalpConds.Length)]; hair_damage = @("None","Low","Medium")[(Get-Random -Maximum 3)]; hair_density = @("Low","Medium","High")[(Get-Random -Maximum 3)]; overall_score = (Get-Random -Minimum 45 -Maximum 90)}
    Invoke-Api -Method Post -Path "/api/resource/Hair Assessment" -Body $haBody -Session $session | Out-Null
  }
}
$script:STATS["Skin Assessments"] = $assessCount
Write-Result -Name "Assessments ($assessCount)" -Passed $true -Detail "$assessCount created"

# ====== PHASE 7: USER ROUTINES ======
Write-Step "PHASE 7: User Routines"
$routineCount = 0
$routineUsers = $createdUsers | Select-Object -First 50
$tplNames = $createdTemplates
foreach ($email in $routineUsers) {
  if ($tplNames.Count -eq 0) { break }
  $tplName = $tplNames[(Get-Random -Maximum $tplNames.Count)]
  $tplResp = Invoke-Api -Method Get -Path "/api/resource/Routine Template/$([System.Uri]::EscapeDataString($tplName))" -Session $session
  $stepsCount = if ($tplResp -and $tplResp.data -and $tplResp.data.steps) { $tplResp.data.steps.Count } else { 3 }
  $steps = @()
  for ($s = 1; $s -le $stepsCount; $s++) {
    $prodName = if ($createdProducts.Count -gt 0) { $createdProducts[(Get-Random -Maximum $createdProducts.Count)] } else { "" }
    $steps += @{step_number = $s; step_name = "Step $s"; product = $prodName; is_completed = if ((Get-Random -Maximum 100) -lt 70) { 1 } else { 0 }}
  }
  $routineBody = @{doctype = "User Routine"; user = $email; routine_template = $tplName; is_active = 1; adherence_rate = (Get-Random -Minimum 40 -Maximum 98); steps = $steps}
  $resp = Invoke-Api -Method Post -Path "/api/resource/User Routine" -Body $routineBody -Session $session
  if ($resp -and $resp.data) { $routineCount++ }

  if ((Get-Random -Maximum 100) -lt 40) {
    $tplName2 = $tplNames | Where-Object { $_ -ne $tplName } | Get-Random
    if ($tplName2) {
      $steps2 = @()
      for ($s = 1; $s -le 3; $s++) { $steps2 += @{step_number = $s; step_name = "Step $s"; product = $createdProducts[(Get-Random -Maximum $createdProducts.Count)]; is_completed = 0} }
      $routineBody2 = @{doctype = "User Routine"; user = $email; routine_template = $tplName2; is_active = 1; adherence_rate = (Get-Random -Minimum 30 -Maximum 90); steps = $steps2}
      $resp2 = Invoke-Api -Method Post -Path "/api/resource/User Routine" -Body $routineBody2 -Session $session
      if ($resp2 -and $resp2.data) { $routineCount++ }
    }
  }
}
$script:STATS["User Routines"] = $routineCount
Write-Result -Name "User Routines ($routineCount)" -Passed $true -Detail "$routineCount routines created"

# ====== PHASE 8: COMMUNITY POSTS ======
Write-Step "PHASE 8: Community Posts"
$postCount = 0
$postUsers = $createdUsers | Select-Object -First 30
$postContents = @(
  "Just finished my 30-day skincare routine! My skin has never looked better. The hydration boost is incredible!",
  "Has anyone tried the new vitamin C serum? I'm thinking of adding it to my morning routine.",
  "Struggling with adult acne at 35. Any product recommendations that won't dry out my skin?",
  "Finally found my holy grail moisturizer! My sensitive skin is loving this ceramide cream.",
  "My curly hair journey update: 3 months of CG method and the difference is amazing!",
  "What's your go-to sunscreen for oily skin? I need something that doesn't make me look greasy.",
  "Just discovered niacinamide and it's changed my skin texture completely. Pores are vanishing!",
  "Starting my retinol journey tonight! Any tips for beginners to minimize irritation?",
  "The power of a good double cleanse cannot be overstated. My skin is so much clearer now.",
  "Beauty tip: Don't forget your neck and chest in your skincare routine! They show age too.",
  "Can we talk about scalp health? Started using a scalp scrub and my hair feels amazing.",
  "Mini review: The hyaluronic acid serum from AuraLab is incredible. So plumping!",
  "My nighttime routine takes 15 minutes and it's my favorite self-care moment of the day.",
  "Question: How do you deal with maskne? My chin is breaking out from wearing masks all day.",
  "Just got my Aura Premium subscription! Excited to try the exclusive products.",
  "For anyone with KP on arms, try lactic acid body lotion. Game changer!",
  "Dry skin girl here. What's your favorite sleeping mask for deep overnight hydration?",
  "Tracking my progress with Aura for 2 weeks now. Love seeing the data and improvements!",
  "Any recs for a gentle retinol for sensitive skin? I want anti-aging without irritation.",
  "My affordable skincare routine that delivers luxury results. Total cost under $50!",
  "Finally figured out my hair porosity and it's transformed my hair care approach.",
  "Hot take: You don't need 10-step routine. Consistency > complexity every time.",
  "Looking for a good vitamin C serum that won't oxidize quickly. Suggestions?",
  "Tried the new peptide moisturizer and my fine lines are actually diminishing!",
  "How long did it take you to see results from retinol? I'm in week 4 with mild improvement.",
  "Posting my 90-day progress photos. The difference in my skin texture is unreal.",
  "Best dandruff shampoo that actually works? Tried everything and still flaking.",
  "Just started using azelaic acid for redness and rosacea. Day 3 and already calmer!",
  "The Aura community is so supportive! Love reading everyone's journeys.",
  "Winter skincare is a whole different ballgame. My moisturizer game has leveled up."
)

foreach ($email in $postUsers) {
  $content = $postContents[(Get-Random -Maximum $postContents.Length)]
  $groupName = if ($createdGroups.Count -gt 0 -and (Get-Random -Maximum 100) -lt 50) { $createdGroups[(Get-Random -Maximum $createdGroups.Count)] } else { "" }
  $postBody = @{doctype = "Community Post"; user = $email; content = $content; group = $groupName; post_type = "Text"; is_published = 1}
  $resp = Invoke-Api -Method Post -Path "/api/resource/Community Post" -Body $postBody -Session $session
  if ($resp -and $resp.data) { $postCount++; $script:CREATED["posts"] += @{id = $resp.data.name; user = $email} }

  if ((Get-Random -Maximum 100) -lt 30) {
    $content2 = $postContents[(Get-Random -Maximum $postContents.Length)]
    $postBody2 = @{doctype = "Community Post"; user = $email; content = $content2; group = ""; post_type = "Text"; is_published = 1}
    $resp2 = Invoke-Api -Method Post -Path "/api/resource/Community Post" -Body $postBody2 -Session $session
    if ($resp2 -and $resp2.data) { $postCount++; $script:CREATED["posts"] += @{id = $resp2.data.name; user = $email} }
  }
}
$script:STATS["Community Posts"] = $postCount
Write-Result -Name "Community Posts ($postCount)" -Passed $true -Detail "$postCount posts created"

# ====== PHASE 9: COMMENTS & LIKES ======
Write-Step "PHASE 9: Comments & Likes"
$allPosts = @()
if ($script:CREATED["posts"]) { $allPosts = $script:CREATED["posts"] | Where-Object { $_.id } }
$commentCount = 0
$likeCount = 0
$commentTexts = @(
  "Great results! Thanks for sharing your journey.","I've been thinking about trying this too!",
  "This is so helpful, thank you!","How long did it take to see these results?",
  "I agree! This product changed my skin too.","Have you tried layering it with niacinamide?",
  "Amazing progress! Keep it up!","What's your skin type? I have similar concerns.",
  "Adding this to my wishlist right now!","The before/after difference is incredible!",
  "Could you share your full routine?","I had a different experience with this product.",
  "Consistency really is key. Well done!","My dermatologist recommended this too!",
  "Thanks for the honest review."
)
$commentUsers = $createdUsers | Select-Object -First 40

foreach ($post in $allPosts) {
  $numComments = Get-Random -Minimum 1 -Maximum 5
  for ($c = 0; $c -lt $numComments -and $c -lt $commentUsers.Count; $c++) {
    $cu = $commentUsers[(Get-Random -Maximum $commentUsers.Count)]
    $ct = $commentTexts[(Get-Random -Maximum $commentTexts.Length)]
    $commentBody = @{doctype = "Community Comment"; post = $post.id; user = $cu; content = $ct}
    $resp = Invoke-Api -Method Post -Path "/api/resource/Community Comment" -Body $commentBody -Session $session
    if ($resp -and $resp.data) { $commentCount++ }
  }
  $numLikes = Get-Random -Minimum 2 -Maximum 11
  for ($l = 0; $l -lt $numLikes -and $l -lt $commentUsers.Count; $l++) {
    $lu = $commentUsers[(Get-Random -Maximum $commentUsers.Count)]
    Invoke-Api -Method Post -Path "/api/method/aura.api.community.toggle_like" -Body @{post = $post.id} -Session $session | Out-Null
    $likeCount++
  }
}
$script:STATS["Comments"] = $commentCount
$script:STATS["Likes"] = $likeCount
Write-Result -Name "Comments ($commentCount)" -Passed $true -Detail "$commentCount comments created"
Write-Result -Name "Likes ($likeCount)" -Passed $true -Detail "$likeCount likes added"

# ====== PHASE 10: PROGRESS & DIARY ENTRIES ======
Write-Step "PHASE 10: Progress & Diary Entries"
$progressCount = 0
$diaryCount = 0
$progressUsers = $createdUsers | Select-Object -First 40
foreach ($email in $progressUsers) {
  $numEntries = Get-Random -Minimum 5 -Maximum 16
  for ($d = 0; $d -lt $numEntries; $d++) {
    $dayOffset = -$d
    $entryDate = (Get-Date).AddDays($dayOffset).ToString("yyyy-MM-dd")
    $moods = @("Great","Good","Neutral","Low","Stressed")
    $sleeps = @("Poor","Fair","Good","Excellent")
    $peBody = @{doctype = "Progress Entry"; user = $email; entry_date = $entryDate; skin_score = Get-Random -Minimum 55 -Maximum 95; hair_score = Get-Random -Minimum 50 -Maximum 90; mood = $moods[(Get-Random -Maximum $moods.Length)]; sleep_quality = $sleeps[(Get-Random -Maximum $sleeps.Length)]}
    $resp = Invoke-Api -Method Post -Path "/api/resource/Progress Entry" -Body $peBody -Session $session
    if ($resp -and $resp.data) { $progressCount++ }

    if ((Get-Random -Maximum 100) -lt 40) {
      $skinConds = @("Clear","Minor Breakout","Dry","Oily","Red")
      $deBody = @{doctype = "Beauty Diary Entry"; user = $email; entry_date = $entryDate; mood = $moods[(Get-Random -Maximum $moods.Length)]; sleep_hours = [math]::Round((Get-Random -Minimum 5 -Maximum 9) + (Get-Random -Maximum 10) / 10, 1); water_intake = @("Low","Medium","High")[(Get-Random -Maximum 3)]; stress_level = @("Low","Medium","High")[(Get-Random -Maximum 3)]; skin_condition = $skinConds[(Get-Random -Maximum $skinConds.Length)]}
      $resp = Invoke-Api -Method Post -Path "/api/resource/Beauty Diary Entry" -Body $deBody -Session $session
      if ($resp -and $resp.data) { $diaryCount++ }
    }
  }
}
$script:STATS["Progress Entries"] = $progressCount
$script:STATS["Diary Entries"] = $diaryCount
Write-Result -Name "Progress Entries ($progressCount)" -Passed $true -Detail "$progressCount entries created"
Write-Result -Name "Diary Entries ($diaryCount)" -Passed $true -Detail "$diaryCount entries created"

# ====== PHASE 11: PRICE ALERTS ======
Write-Step "PHASE 11: Price Alerts"
$alertCount = 0
$alertUsers = $createdUsers | Select-Object -First 25
foreach ($email in $alertUsers) {
  if ($createdProducts.Count -eq 0) { break }
  $prodName = $createdProducts[(Get-Random -Maximum $createdProducts.Count)]
  $price = [math]::Round((Get-Random -Minimum 10 -Maximum 55) + (Get-Random -Maximum 99) / 100, 2)
  $target = [math]::Round($price * (Get-Random -Minimum 70 -Maximum 90) / 100, 2)
  $alertBody = @{doctype = "Price Alert"; user = $email; product = $prodName; current_price = $price; target_price = $target; is_triggered = if ((Get-Random -Maximum 100) -lt 20) { 1 } else { 0 }}
  $resp = Invoke-Api -Method Post -Path "/api/resource/Price Alert" -Body $alertBody -Session $session
  if ($resp -and $resp.data) { $alertCount++ }
}
$script:STATS["Price Alerts"] = $alertCount
Write-Result -Name "Price Alerts ($alertCount)" -Passed $true -Detail "$alertCount alerts created"

# ====== PHASE 12: USER BADGES ======
Write-Step "PHASE 12: User Badges"
$userBadgeCount = 0
$badgeUsers = $createdUsers | Select-Object -First 50
foreach ($email in $badgeUsers) {
  if ($createdBadges.Count -eq 0) { break }
  $numBadges = Get-Random -Minimum 1 -Maximum 6
  $selectedBadges = $createdBadges | Get-Random -Count $numBadges
  foreach ($bName in $selectedBadges) {
    $ubBody = @{doctype = "User Badge"; user = $email; badge = $bName; is_earned = 1; progress = 100; earned_date = (Get-Date).AddDays(-(Get-Random -Minimum 1 -Maximum 60)).ToString("yyyy-MM-dd HH:mm:ss")}
    $resp = Invoke-Api -Method Post -Path "/api/resource/User Badge" -Body $ubBody -Session $session
    if ($resp -and $resp.data) { $userBadgeCount++ }
  }
}
$script:STATS["User Badges"] = $userBadgeCount
Write-Result -Name "User Badges ($userBadgeCount)" -Passed $true -Detail "$userBadgeCount badges awarded"

# ====== PHASE 13: AI CONVERSATIONS ======
Write-Step "PHASE 13: AI Coach Conversations"
$aiCount = 0
$aiUsers = $createdUsers | Select-Object -First 30
$aiQuestions = @(
  @{message = "What's a good basic skincare routine for beginners?"; response = "A basic routine has 3 steps..."; context = "Routine"},
  @{message = "My skin is so oily. What can I do?"; response = "Oily skin benefits from: niacinamide to regulate sebum..."; context = "Skin Concern"},
  @{message = "How do I fade dark spots?"; response = "Dark spots can be treated with: vitamin C..."; context = "Skin Concern"},
  @{message = "Is retinol safe to use every night?"; response = "Start slow with retinol: once a week..."; context = "Product"},
  @{message = "What ingredients shouldn't I use together?"; response = "Avoid mixing: vitamin C with benzoyl peroxide..."; context = "Product"},
  @{message = "How can I improve my hair growth?"; response = "For healthier hair growth: use a scalp serum..."; context = "Hair Concern"},
  @{message = "I have dandruff that won't go away"; response = "Stubborn dandruff may need a rotation..."; context = "Hair Concern"},
  @{message = "What's the best way to treat acne scars?"; response = "Acne scars improve with: silicone sheets..."; context = "Skin Concern"},
  @{message = "Recommend a skincare routine for dry skin"; response = "For dry skin: use a cream cleanser..."; context = "Routine"},
  @{message = "What should I eat for better skin?"; response = "Skin-healthy foods include: fatty fish..."; context = "General"}
)
foreach ($email in $aiUsers) {
  $numConvs = Get-Random -Minimum 1 -Maximum 5
  for ($c = 0; $c -lt $numConvs; $c++) {
    $qa = $aiQuestions[(Get-Random -Maximum $aiQuestions.Length)]
    $convBody = @{doctype = "AI Conversation"; user = $email; message = $qa.message; response = $qa.response; context = $qa.context; is_helpful = if ((Get-Random -Maximum 100) -lt 80) { 1 } else { 0 }}
    $resp = Invoke-Api -Method Post -Path "/api/resource/AI Conversation" -Body $convBody -Session $session
    if ($resp -and $resp.data) { $aiCount++ }
  }
}
$script:STATS["AI Conversations"] = $aiCount
Write-Result -Name "AI Conversations ($aiCount)" -Passed $true -Detail "$aiCount conversations created"

# ====== PHASE 14: SKIN ANALYSIS RESULTS ======
Write-Step "PHASE 14: Skin Analysis Results"
$analysisCount = 0
$analysisUsers = $createdUsers | Select-Object -First 25
foreach ($email in $analysisUsers) {
  $haBody = @{doctype = "Skin Analysis Result"; user = $email; hydration_score = (Get-Random -Minimum 30 -Maximum 95); pore_visibility = (Get-Random -Minimum 10 -Maximum 80); texture_score = (Get-Random -Minimum 35 -Maximum 90); pigmentation_score = (Get-Random -Minimum 10 -Maximum 70); redness_score = (Get-Random -Minimum 5 -Maximum 65); overall_score = (Get-Random -Minimum 40 -Maximum 92); findings = "Analysis completed successfully."; recommendations = "Continue current routine with focus on hydration and SPF."}
  $resp = Invoke-Api -Method Post -Path "/api/resource/Skin Analysis Result" -Body $haBody -Session $session
  if ($resp -and $resp.data) { $analysisCount++ }
}
$script:STATS["Skin Analysis Results"] = $analysisCount
Write-Result -Name "Skin Analysis Results ($analysisCount)" -Passed $true -Detail "$analysisCount results created"

# ====== PHASE 15: RECOMMENDATION RESULTS ======
Write-Step "PHASE 15: Recommendation Results"
$recCount = 0
$recUsers = $createdUsers | Select-Object -First 30
foreach ($email in $recUsers) {
  $numRecs = Get-Random -Minimum 1 -Maximum 4
  $recProducts = @()
  for ($r = 0; $r -lt $numRecs -and $r -lt $createdProducts.Count; $r++) {
    $prodName = $createdProducts[(Get-Random -Maximum $createdProducts.Count)]
    $recProducts += @{product = $prodName; score = [math]::Round((Get-Random -Minimum 60 -Maximum 99) / 100, 2); reason = "Recommended based on your skin profile and concerns"; routine_step = @("Cleanser","Serum","Moisturizer","Treatment")[(Get-Random -Maximum 4)]}
  }
  if ($recProducts.Count -gt 0) {
    $recBody = @{doctype = "Recommendation Result"; user = $email; recommendation_type = "Products"; score = (Get-Random -Minimum 60 -Maximum 95); products = $recProducts}
    $resp = Invoke-Api -Method Post -Path "/api/resource/Recommendation Result" -Body $recBody -Session $session
    if ($resp -and $resp.data) { $recCount++ }
  }
}
$script:STATS["Recommendation Results"] = $recCount
Write-Result -Name "Recommendation Results ($recCount)" -Passed $true -Detail "$recCount results created"

# ====== PHASE 16: MARKETPLACE ORDERS ======
Write-Step "PHASE 16: Marketplace Orders"
$orderCount = 0
$orderUsers = $createdUsers | Select-Object -First 20
foreach ($email in $orderUsers) {
  if ($createdProducts.Count -eq 0 -or $createdPartners.Count -eq 0) { break }
  $partnerName = $createdPartners[(Get-Random -Maximum $createdPartners.Count)]
  $numItems = Get-Random -Minimum 1 -Maximum 4
  $items = @()
  $total = 0
  for ($i = 0; $i -lt $numItems; $i++) {
    $pName = $createdProducts[(Get-Random -Maximum $createdProducts.Count)]
    $qty = Get-Random -Minimum 1 -Maximum 3
    $unitPrice = [math]::Round((Get-Random -Minimum 15 -Maximum 65) + (Get-Random -Maximum 99) / 100, 2)
    $total += $unitPrice * $qty
    $items += @{product = $pName; quantity = $qty; unit_price = $unitPrice}
  }
  $ordStatuses = @("Pending","Confirmed","Processing","Shipped","Delivered")
  $payStatuses = @("Pending","Paid","Refunded")
  $orderBody = @{doctype = "Marketplace Order"; partner = $partnerName; user = $email; items = $items; total_price = [math]::Round($total, 2); order_status = $ordStatuses[(Get-Random -Maximum $ordStatuses.Length)]; payment_status = $payStatuses[(Get-Random -Maximum $payStatuses.Length)]}
  $resp = Invoke-Api -Method Post -Path "/api/resource/Marketplace Order" -Body $orderBody -Session $session
  if ($resp -and $resp.data) { $orderCount++ }
}
$script:STATS["Marketplace Orders"] = $orderCount
Write-Result -Name "Marketplace Orders ($orderCount)" -Passed $true -Detail "$orderCount orders created"

# ====== PHASE 17: CHALLENGES ======
Write-Step "PHASE 17: Challenges"
$challengeCount = 0
$challenges = @(
  @{challenge_name = "30-Day Hydration Challenge"; description = "Drink 8 glasses of water daily"; duration_days = 30; category = "Skin"; is_active = 1},
  @{challenge_name = "7-Day No Heat Hair Challenge"; description = "No heat styling for one week"; duration_days = 7; category = "Hair"; is_active = 1},
  @{challenge_name = "21-Day Consistency Challenge"; description = "Complete AM/PM routine for 21 days"; duration_days = 21; category = "Skin"; is_active = 1},
  @{challenge_name = "14-Day Clean Beauty Challenge"; description = "Switch to clean beauty products"; duration_days = 14; category = "Lifestyle"; is_active = 1},
  @{challenge_name = "60-Day Transformation Challenge"; description = "Follow Aura routine for 60 days"; duration_days = 60; category = "Skin"; is_active = 1}
)
foreach ($ch in $challenges) {
  $chBody = $ch | ConvertTo-Json -Depth 10 | ConvertFrom-Json
  Add-Member -InputObject $chBody -NotePropertyName "doctype" -NotePropertyValue "Challenge"
  $resp = Invoke-Api -Method Post -Path "/api/resource/Challenge" -Body $chBody -Session $session
  if ($resp -and $resp.data) { $challengeCount++ }
}
$script:STATS["Challenges"] = $challengeCount
Write-Result -Name "Challenges ($challengeCount)" -Passed ($challengeCount -gt 0) -Detail "$challengeCount challenges created"

# ====== VERIFICATION ======
Write-Step "VERIFICATION: Testing All API Endpoints"
$getTests = @(
  @{Name = "get_profile"; Path = "/api/method/aura.api.profile.get_profile"; ExpectArray = $false}
  @{Name = "get_products"; Path = "/api/method/aura.api.products.get_products"; ExpectArray = $true}
  @{Name = "get_plans"; Path = "/api/method/aura.api.subscriptions.get_plans"; ExpectArray = $true}
  @{Name = "get_feed"; Path = "/api/method/aura.api.community.get_feed"; ExpectArray = $true}
  @{Name = "get_groups"; Path = "/api/method/aura.api.community.get_groups"; ExpectArray = $true}
  @{Name = "get_routines"; Path = "/api/method/aura.api.routines.get_routines"; ExpectArray = $true}
  @{Name = "get_templates"; Path = "/api/method/aura.api.routines.get_templates"; ExpectArray = $true}
  @{Name = "get_progress"; Path = "/api/method/aura.api.progress.get_progress"; ExpectArray = $true}
  @{Name = "get_my_badges"; Path = "/api/method/aura.api.badges.get_my_badges"; ExpectArray = $true}
  @{Name = "get_all_badges"; Path = "/api/method/aura.api.badges.get_all_badges"; ExpectArray = $true}
  @{Name = "get_ingredients"; Path = "/api/method/aura.api.ingredients.get_ingredients"; ExpectArray = $true}
  @{Name = "get_conflicts"; Path = "/api/method/aura.api.ingredients.get_conflicts"; ExpectArray = $true}
  @{Name = "analyze_needs"; Path = "/api/method/aura.api.need_analyzer.analyze_needs"; ExpectArray = $false}
  @{Name = "get_assessment_history"; Path = "/api/method/aura.api.assessments.get_assessment_history"; ExpectArray = $true}
  @{Name = "get_recommendations"; Path = "/api/method/aura.api.recommendations.get_recommendations"; ExpectArray = $false}
  @{Name = "get_chat_history"; Path = "/api/method/aura.api.ai_coach.get_history"; ExpectArray = $true}
  @{Name = "get_marketplace_orders"; Path = "/api/method/aura.api.marketplace.partner_get_orders"; ExpectArray = $true}
)
$verifyPass = 0
$verifyFail = 0
foreach ($test in $getTests) {
  try {
    $resp = Invoke-Api -Method Get -Path $test.Path -Session $session
    if (-not $resp) { Write-Host "  [FAIL] $($test.Name): No response" -ForegroundColor Red; $verifyFail++; continue }
    $msg = $resp.message
    if ($test.ExpectArray) {
      if ($msg -is [System.Array]) {
        $count = $msg.Count
        $status = if ($count -gt 0) { "($count items)" } else { "(empty)" }
        Write-Host "  $(if ($count -gt 0) { '[PASS]' } else { '[WARN]' }) $($test.Name): $count items returned" -ForegroundColor $(if ($count -gt 0) { "Green" } else { "Yellow" })
        if ($count -gt 0) { $verifyPass++ } else { $verifyFail++ }
      } else { Write-Host "  [FAIL] $($test.Name): Expected array, got $($msg.GetType().Name)" -ForegroundColor Red; $verifyFail++ }
    } else {
      if ($msg) { Write-Host "  [PASS] $($test.Name): object returned" -ForegroundColor Green; $verifyPass++ }
      else { Write-Host "  [FAIL] $($test.Name): null" -ForegroundColor Red; $verifyFail++ }
    }
  } catch { Write-Host "  [FAIL] $($test.Name): $($_.Exception.Message)" -ForegroundColor Red; $verifyFail++ }
}

# ====== SUMMARY ======
Write-Step "SEEDING COMPLETE - SUMMARY"
Write-Host ""
Write-Host "Records Created by DocType:" -ForegroundColor Cyan
Write-Host "  Concern Tags:       $($STATS['Concern Tags'])" -ForegroundColor White
Write-Host "  Product Ingredients: $($STATS['Product Ingredients'])" -ForegroundColor White
Write-Host "  Subscription Plans: $($STATS['Subscription Plans'])" -ForegroundColor White
Write-Host "  Community Groups:   $($STATS['Community Groups'])" -ForegroundColor White
Write-Host "  Achievement Badges: $($STATS['Achievement Badges'])" -ForegroundColor White
Write-Host "  Routine Templates:  $($STATS['Routine Templates'])" -ForegroundColor White
Write-Host "  Marketplace Partners: $($STATS['Marketplace Partners'])" -ForegroundColor White
Write-Host "  Ingredient Conflicts: $($STATS['Ingredient Conflicts'])" -ForegroundColor White
Write-Host "  Beauty Products:    $($STATS['Beauty Products'])" -ForegroundColor White
Write-Host "  Users:              $($STATS['Users'])" -ForegroundColor White
Write-Host "  User Profiles:      $($STATS['Beauty User Profiles'])" -ForegroundColor White
Write-Host "  User Subscriptions: $($STATS['User Subscriptions'])" -ForegroundColor White
Write-Host "  Skin Assessments:   $($STATS['Skin Assessments'])" -ForegroundColor White
Write-Host "  User Routines:      $($STATS['User Routines'])" -ForegroundColor White
Write-Host "  Community Posts:    $($STATS['Community Posts'])" -ForegroundColor White
Write-Host "  Comments:           $($STATS['Comments'])" -ForegroundColor White
Write-Host "  Likes:              $($STATS['Likes'])" -ForegroundColor White
Write-Host "  Progress Entries:   $($STATS['Progress Entries'])" -ForegroundColor White
Write-Host "  Diary Entries:      $($STATS['Diary Entries'])" -ForegroundColor White
Write-Host "  Price Alerts:       $($STATS['Price Alerts'])" -ForegroundColor White
Write-Host "  User Badges:        $($STATS['User Badges'])" -ForegroundColor White
Write-Host "  AI Conversations:   $($STATS['AI Conversations'])" -ForegroundColor White
Write-Host "  Skin Analysis Res:  $($STATS['Skin Analysis Results'])" -ForegroundColor White
Write-Host "  Recommendation Res: $($STATS['Recommendation Results'])" -ForegroundColor White
Write-Host "  Marketplace Orders: $($STATS['Marketplace Orders'])" -ForegroundColor White
Write-Host "  Challenges:         $($STATS['Challenges'])" -ForegroundColor White
Write-Host ""
Write-Host "API Verification:" -ForegroundColor Cyan
Write-Host "  Passed: $verifyPass" -ForegroundColor Green
Write-Host "  Failed: $verifyFail" -ForegroundColor Red
Write-Host ""
Write-Host "Total Created Records: $(($STATS.Values | Measure-Object -Sum).Sum)" -ForegroundColor Cyan

if ($FAILED.Count -gt 0) {
  Write-Host "`nFailures during seeding:" -ForegroundColor Yellow
  foreach ($f in $FAILED) { Write-Host "  - $f" -ForegroundColor Yellow }
}
Write-Host "`nDemo users password: Demo@2026!" -ForegroundColor Gray
if ($createdUsers.Count -gt 0) { Write-Host "First demo user: $($createdUsers[0]) / Demo@2026!" -ForegroundColor Gray }
Write-Host "`nDone!" -ForegroundColor Cyan
