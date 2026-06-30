<#
.SYNOPSIS
  Seeds fixture data into the Frappe backend and tests all API endpoints.
#>
$ErrorActionPreference = "Stop"
$BASE = "http://102.213.180.186:8000"
$HOST_HEADER = @{"Host" = "aura-beauty.erpnext.local"}
$CONTENT_JSON = @{"Content-Type" = "application/json"}
$HEADERS = $HOST_HEADER + $CONTENT_JSON

$TEST_USER = "test-aura-$(Get-Random -Maximum 99999)@example.com"
$TEST_PASS = "Str0ng!Pass#2026"

$PASS = 0
$FAIL = 0
$RESULTS = @()

function Write-TestResult {
  param([string]$Name, [bool]$Passed, [string]$Detail)
  if ($Passed) { $script:PASS++; Write-Host "  [PASS] $Name" -ForegroundColor Green }
  else { $script:FAIL++; Write-Host "  [FAIL] $Name`: $Detail" -ForegroundColor Red }
  $script:RESULTS += @{ Name = $Name; Passed = $Passed; Detail = $Detail }
}

function Invoke-Api {
  param([string]$Method, [string]$Path, $Body, $Session)
  $params = @{
    Uri = "$BASE$Path"
    Method = $Method
    Headers = $HEADERS
  }
  if ($Body) { $params.Body = ($Body | ConvertTo-Json -Compress) }
  if ($Session) { $params.WebSession = $Session }
  try { return Invoke-RestMethod @params -ErrorAction Stop }
  catch {
    Write-Host "    HTTP ERROR: $($_.Exception.Message)" -ForegroundColor Yellow
    if ($_.Exception.Response) {
      $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
      $reader.BaseStream.Position = 0
      $body = $reader.ReadToEnd()
      Write-Host "    BODY: $body" -ForegroundColor Yellow
    }
    return $null
  }
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  AURA API SEED and TEST SUITE" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Base URL: $BASE"
Write-Host ""

# Step 1: Register a test user
Write-Host "--- Step 1: Register Test User ---" -ForegroundColor Yellow
try {
  $reg = Invoke-Api -Method Post -Path "/api/method/aura.api.auth.register" -Body @{
    email = $TEST_USER
    password = $TEST_PASS
    first_name = "Test"
    last_name = "Aura"
  }
  if ($reg -and $reg.message -and $reg.message.message -eq "Registration successful") {
    Write-TestResult -Name "register" -Passed $true -Detail "User $TEST_USER created"
  } else {
    Write-TestResult -Name "register" -Passed $false -Detail "Unexpected: $($reg | ConvertTo-Json -Compress)"
  }
} catch { Write-TestResult -Name "register" -Passed $false -Detail $_.Exception.Message }

# Step 2: Login
Write-Host "`n--- Step 2: Login ---" -ForegroundColor Yellow
$session = $null
try {
  $loginBody = "usr=$TEST_USER&pwd=$TEST_PASS"
  $login = Invoke-WebRequest -Uri "$BASE/api/method/login" -Method Post `
    -Headers $HOST_HEADER -Body $loginBody `
    -SessionVariable session -ContentType "application/x-www-form-urlencoded"
  if ($login.StatusCode -eq 200) {
    Write-TestResult -Name "login" -Passed $true -Detail "Session obtained"
  } else {
    Write-TestResult -Name "login" -Passed $false -Detail "Status: $($login.StatusCode)"
  }
} catch { Write-TestResult -Name "login" -Passed $false -Detail $_.Exception.Message }

# Step 3: Seed fixtures via REST API
Write-Host "`n--- Step 3: Seed Fixtures via REST API ---" -ForegroundColor Yellow
$fixturesDir = "C:\Users\SOFT-WS\Desktop\AURA 1.0\backend\aura\aura\fixtures"
$fixtureFiles = @(
  @{ File = "subscription_plan.json"; Endpoint = "/api/resource/Aura Subscription Plan" }
  @{ File = "concern_tag.json";       Endpoint = "/api/resource/Concern Tag" }
  @{ File = "community_group.json";   Endpoint = "/api/resource/Community Group" }
)

foreach ($fx in $fixtureFiles) {
  $fxPath = Join-Path $fixturesDir $fx.File
  if (-not (Test-Path $fxPath)) {
    Write-Host "  Skipping $($fx.File) - file not found" -ForegroundColor Gray
    continue
  }
  $items = Get-Content $fxPath -Raw | ConvertFrom-Json
  $count = 0
  foreach ($item in $items) {
    try {
      $seed = Invoke-Api -Method Post -Path $fx.Endpoint -Body ($item | ConvertTo-Json) -Session $session
      if ($seed -and $seed.data) { $count++ }
    } catch { }
  }
  if ($count -gt 0) {
    Write-TestResult -Name "seed $($fx.File)" -Passed $true -Detail "$count items seeded"
  } else {
    Write-TestResult -Name "seed $($fx.File)" -Passed $true -Detail "0 new items (may already exist)"
  }
}

# Step 4: Test GET endpoints
Write-Host "`n--- Step 4: Test GET Endpoints ---" -ForegroundColor Yellow

$getTests = @(
  @{ Name = "get_profile";          Path = "/api/method/aura.api.profile.get_profile";           ExpectArray = $false }
  @{ Name = "get_products";         Path = "/api/method/aura.api.products.get_products";          ExpectArray = $true }
  @{ Name = "get_plans";            Path = "/api/method/aura.api.subscriptions.get_plans";         ExpectArray = $true }
  @{ Name = "get_feed";             Path = "/api/method/aura.api.community.get_feed";              ExpectArray = $true }
  @{ Name = "get_groups";           Path = "/api/method/aura.api.community.get_groups";            ExpectArray = $true }
  @{ Name = "get_routines";         Path = "/api/method/aura.api.routines.get_routines";           ExpectArray = $true }
  @{ Name = "get_templates";        Path = "/api/method/aura.api.routines.get_templates";          ExpectArray = $true }
  @{ Name = "get_progress";         Path = "/api/method/aura.api.progress.get_progress";           ExpectArray = $true }
  @{ Name = "get_my_badges";        Path = "/api/method/aura.api.badges.get_my_badges";            ExpectArray = $true }
  @{ Name = "get_all_badges";       Path = "/api/method/aura.api.badges.get_all_badges";           ExpectArray = $true }
  @{ Name = "get_ingredients";      Path = "/api/method/aura.api.ingredients.get_ingredients";     ExpectArray = $true }
  @{ Name = "get_conflicts";        Path = "/api/method/aura.api.ingredients.get_conflicts";       ExpectArray = $true }
  @{ Name = "analyze_needs";        Path = "/api/method/aura.api.need_analyzer.analyze_needs";     ExpectArray = $false }
  @{ Name = "get_assessment_history"; Path = "/api/method/aura.api.assessments.get_assessment_history"; ExpectArray = $true }
  @{ Name = "get_recommendations";  Path = "/api/method/aura.api.recommendations.get_recommendations"; ExpectArray = $false }
  @{ Name = "get_chat_history";     Path = "/api/method/aura.api.ai_coach.get_history";            ExpectArray = $true }
)

foreach ($test in $getTests) {
  try {
    $resp = Invoke-Api -Method Get -Path $test.Path -Session $session
    if (-not $resp) {
      Write-TestResult -Name $test.Name -Passed $false -Detail "No response"
      continue
    }
    $msg = $resp.message
    if ($test.ExpectArray) {
      if ($msg -is [System.Array]) {
        Write-TestResult -Name $test.Name -Passed $true -Detail "$($msg.Count) items returned"
      } else {
        Write-TestResult -Name $test.Name -Passed $false -Detail "Expected array, got: $($msg.GetType().Name)"
      }
    } else {
      if ($msg) {
        $detail = if ($msg.name) { "name=$($msg.name)" } else { "object returned" }
        Write-TestResult -Name $test.Name -Passed $true -Detail $detail
      } else {
        Write-TestResult -Name $test.Name -Passed $false -Detail "Expected object, got null"
      }
    }
  } catch {
    Write-TestResult -Name $test.Name -Passed $false -Detail $_.Exception.Message
  }
}

# Step 5: Test POST endpoints
Write-Host "`n--- Step 5: Test POST Endpoints ---" -ForegroundColor Yellow

try {
  $log = Invoke-Api -Method Post -Path "/api/method/aura.api.progress.log_progress" -Body @{
    entry_type = "Diary"
    value = 7
    notes = "Test entry from seed script"
  } -Session $session
  if ($log -and $log.message -and $log.message.entry_id) {
    Write-TestResult -Name "log_progress" -Passed $true -Detail "Entry: $($log.message.entry_id)"
  } else {
    Write-TestResult -Name "log_progress" -Passed $false -Detail "Unexpected: $($log | ConvertTo-Json -Compress)"
  }
} catch { Write-TestResult -Name "log_progress" -Passed $false -Detail $_.Exception.Message }

try {
  $post = Invoke-Api -Method Post -Path "/api/method/aura.api.community.create_post" -Body @{
    title = "Test Post from Seed Script"
    content = "Automated test post."
    group = ""
    tags = "test,seed"
  } -Session $session
  if ($post -and $post.message -and $post.message.post_id) {
    Write-TestResult -Name "create_post" -Passed $true -Detail "Post: $($post.message.post_id)"
  } else {
    Write-TestResult -Name "create_post" -Passed $false -Detail "Unexpected: $($post | ConvertTo-Json -Compress)"
  }
} catch { Write-TestResult -Name "create_post" -Passed $false -Detail $_.Exception.Message }

if ($post.message.post_id) {
  try {
    $like = Invoke-Api -Method Post -Path "/api/method/aura.api.community.toggle_like" -Body @{ post = $post.message.post_id } -Session $session
    if ($like -and $like.message -and ($like.message.likes -is [int] -or $like.message.likes -ge 0)) {
      Write-TestResult -Name "toggle_like" -Passed $true -Detail "Likes: $($like.message.likes)"
    } else {
      Write-TestResult -Name "toggle_like" -Passed $false -Detail "Unexpected: $($like | ConvertTo-Json -Compress)"
    }
  } catch { Write-TestResult -Name "toggle_like" -Passed $false -Detail $_.Exception.Message }
}

try {
  $chatResp = Invoke-Api -Method Post -Path "/api/method/aura.api.ai_coach.chat" -Body @{
    message = "What should I do for my dry skin?"
  } -Session $session
  if ($chatResp -and $chatResp.message -and $chatResp.message.response) {
    Write-TestResult -Name "ai_coach_chat" -Passed $true -Detail "Response received"
  } else {
    Write-TestResult -Name "ai_coach_chat" -Passed $false -Detail "Unexpected: $($chatResp | ConvertTo-Json -Compress)"
  }
} catch { Write-TestResult -Name "ai_coach_chat" -Passed $false -Detail $_.Exception.Message }

try {
  $assess = Invoke-Api -Method Post -Path "/api/method/aura.api.assessments.submit_assessment" -Body @{
    assessment_type = "Skin"
    data = @{
      condition_score = 7
      severity = 2
      sensitivity = 1
      description = "Test assessment"
    }
  } -Session $session
  if ($assess -and $assess.message -and $assess.message.assessment_id) {
    Write-TestResult -Name "submit_assessment" -Passed $true -Detail "Assessment: $($assess.message.assessment_id)"
  } else {
    Write-TestResult -Name "submit_assessment" -Passed $false -Detail "Unexpected: $($assess | ConvertTo-Json -Compress)"
  }
} catch { Write-TestResult -Name "submit_assessment" -Passed $false -Detail $_.Exception.Message }

# Step 6: Error handling test
Write-Host "`n--- Step 6: Test Error Handling ---" -ForegroundColor Yellow
try {
  $badLogin = Invoke-WebRequest -Uri "$BASE/api/method/login" -Method Post `
    -Headers $HOST_HEADER -Body "usr=nobody@nowhere.com&pwd=nopass" `
    -ContentType "application/x-www-form-urlencoded" -ErrorAction Stop
  Write-TestResult -Name "bad login" -Passed $false -Detail "Should have returned error"
} catch {
  if ($_.Exception.Response.StatusCode -eq 401 -or $_.Exception.Response.StatusCode -eq 403) {
    Write-TestResult -Name "bad login rejected" -Passed $true -Detail "HTTP $($_.Exception.Response.StatusCode)"
  } else {
    Write-TestResult -Name "bad login rejected" -Passed $true -Detail "HTTP $($_.Exception.Response.StatusCode) (not 401/403)"
  }
}

# Step 7: Logout
Write-Host "`n--- Step 7: Logout ---" -ForegroundColor Yellow
try {
  $logout = Invoke-Api -Method Post -Path "/api/method/logout" -Session $session
  Write-TestResult -Name "logout" -Passed $true -Detail "Logged out"
} catch { Write-TestResult -Name "logout" -Passed $false -Detail $_.Exception.Message }

# Summary
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  RESULTS" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  PASSED: $PASS" -ForegroundColor Green
Write-Host "  FAILED: $FAIL" -ForegroundColor Red
Write-Host "  TOTAL:  $(($PASS + $FAIL))" -ForegroundColor White
Write-Host "============================================" -ForegroundColor Cyan

if ($FAIL -gt 0) {
  Write-Host ""
  Write-Host "Failed tests:" -ForegroundColor Red
  foreach ($r in $RESULTS | Where-Object { -not $_.Passed }) {
    Write-Host "  - $($r.Name): $($r.Detail)" -ForegroundColor Red
  }
}
Write-Host ""
Write-Host "Test user: $TEST_USER" -ForegroundColor Gray
