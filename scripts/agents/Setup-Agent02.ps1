<#
================================================================================
  Setup-Agent02.ps1  --  AGENT-02 artefact generator
  "Golden Returns Wealth Management" cyber-forensics training lab.

  Role    : Priya Verma -- Lead Generator
  Username: priya.v
  Profile : C:\Users\priya.v
  IP      : 192.168.10.22

  *** SYNTHETIC TRAINING DATA ONLY ***
  All names, phones, accounts, and content are entirely fictional and
  machine-generated for an isolated DSP forensics training exercise.
  Any resemblance to real persons or entities is purely coincidental.

  Requirements : PowerShell 5.1, .NET 4.x, Windows 10.
                 Dot-sourced by 00-Master-Setup.ps1 which has already
                 loaded shared\New-FakeData.ps1.
================================================================================
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Dot-source shared library when this script is invoked standalone.
if (-not (Get-Variable -Name 'VictimData' -Scope Global -ErrorAction SilentlyContinue)) {
    . "$PSScriptRoot\..\shared\New-FakeData.ps1"
}

function Invoke-RoleSetup {
    <#
        Creates all AGENT-02 evidence artefacts.
        Returns @{ Role='AGENT-02'; FilesCreated=N; Errors=@() }
    #>

    $role        = 'AGENT-02'
    $profileBase = "$env:SystemDrive\Users\priya.v"
    $filesCreated = 0
    $errors       = [System.Collections.Generic.List[string]]::new()

    Write-SetupLog "[$role] Invoke-RoleSetup starting -- profile: $profileBase"

    # ==================================================================
    # 1. Desktop\leads_apr2026.csv
    # ==================================================================
    Write-SetupLog "[$role] Step 1: leads_apr2026.csv"
    try {
        $destDir = "$profileBase\Desktop"
        New-DirectoryIfMissing $destDir

        $csvPath = "$destDir\leads_apr2026.csv"
        Write-SetupLog "[$role] Exporting $($LeadData.Count) leads to CSV..."
        $LeadData | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
        Add-HashRecord -FilePath $csvPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $csvPath ($($LeadData.Count) rows)"
    } catch {
        $msg = "[$role] Step 1 FAILED (leads_apr2026.csv): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 2. Desktop\Sales_Nav_Renewal.txt
    # ==================================================================
    Write-SetupLog "[$role] Step 2: Sales_Nav_Renewal.txt"
    try {
        $destDir = "$profileBase\Desktop"
        New-DirectoryIfMissing $destDir

        $renewalContent = @"
LinkedIn Sales Navigator -- Renewal Reminder
Account: priya.verma@goldenreturns.example
Plan: Advanced (Monthly)
Next billing: 01-May-2026
Amount: USD 99.99
Auto-renew: ON
Note: Approve with Arjun before 28-Apr
"@

        $renewalPath = "$destDir\Sales_Nav_Renewal.txt"
        [System.IO.File]::WriteAllText($renewalPath, $renewalContent, [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $renewalPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $renewalPath"
    } catch {
        $msg = "[$role] Step 2 FAILED (Sales_Nav_Renewal.txt): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 3. Documents\scraping_scripts\linkedin_scrape.py
    # ==================================================================
    Write-SetupLog "[$role] Step 3: linkedin_scrape.py"
    try {
        $destDir = "$profileBase\Documents\scraping_scripts"
        New-DirectoryIfMissing $destDir

        $pythonScript = @'
"""
linkedin_scrape.py  --  LinkedIn profile scraper for investment lead generation.
Searches for profiles matching investment-interested individuals in India.

Usage:
    python linkedin_scrape.py

Output:
    leads_raw.csv  (same directory)

WARNING: Web scraping LinkedIn may violate their Terms of Service.
         This script is for educational/research purposes only.
"""

import requests
from bs4 import BeautifulSoup
import csv
import time
import random
import logging
import os
from datetime import datetime

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
SEARCH_QUERY    = "investment interested portfolio India"
BASE_URL        = "https://www.linkedin.com"
LOGIN_URL       = "https://www.linkedin.com/login"
SEARCH_URL      = "https://www.linkedin.com/search/results/people/"
OUTPUT_FILE     = "leads_raw.csv"
MAX_PAGES       = 20
MIN_DELAY_SEC   = 2.5
MAX_DELAY_SEC   = 6.0
MAX_RETRIES     = 3

# Rotate User-Agent to reduce detection probability.
USER_AGENTS = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:124.0) "
    "Gecko/20100101 Firefox/124.0",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 "
    "(KHTML, like Gecko) Version/17.3 Safari/605.1.15",
]

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
log = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# LinkedInScraper class
# ---------------------------------------------------------------------------
class LinkedInScraper:
    """
    Handles LinkedIn session management, profile search, data extraction,
    and CSV export for the Golden Returns lead pipeline.
    """

    def __init__(self, username: str, password: str):
        self.username = username
        self.password = password
        self.session  = requests.Session()
        self.session.headers.update({
            "User-Agent"      : random.choice(USER_AGENTS),
            "Accept-Language" : "en-US,en;q=0.9,hi;q=0.8",
            "Accept-Encoding" : "gzip, deflate, br",
            "Referer"         : BASE_URL,
        })
        self._logged_in = False

    # ------------------------------------------------------------------
    def login(self) -> bool:
        """
        Authenticates against LinkedIn using a POST to the login endpoint.
        Extracts the CSRF token from the login page before submitting.
        Returns True on success, False on failure.
        """
        log.info("Fetching login page for CSRF token...")
        try:
            resp = self.session.get(LOGIN_URL, timeout=15)
            resp.raise_for_status()
        except requests.RequestException as exc:
            log.error("Failed to fetch login page: %s", exc)
            return False

        soup  = BeautifulSoup(resp.text, "html.parser")
        token_input = soup.find("input", {"name": "loginCsrfParam"})
        csrf  = token_input["value"] if token_input else ""

        payload = {
            "session_key"      : self.username,
            "session_password" : self.password,
            "loginCsrfParam"   : csrf,
            "trk"              : "guest_homepage-basic_sign-in-submit",
        }

        log.info("Submitting login credentials for %s ...", self.username)
        try:
            post_resp = self.session.post(
                LOGIN_URL, data=payload, timeout=15, allow_redirects=True
            )
            post_resp.raise_for_status()
        except requests.RequestException as exc:
            log.error("Login POST failed: %s", exc)
            return False

        # Simple heuristic: check if we landed on the feed page.
        if "feed" in post_resp.url or "checkpoint" not in post_resp.url:
            log.info("Login successful.")
            self._logged_in = True
            return True

        log.warning("Login may have failed -- unexpected redirect to: %s", post_resp.url)
        return False

    # ------------------------------------------------------------------
    def search_profiles(self, query: str = SEARCH_QUERY, max_pages: int = MAX_PAGES):
        """
        Iterates through LinkedIn people-search pages for the given query.
        Yields raw BeautifulSoup result-card elements, one per profile hit.
        Applies random delays between pages to reduce rate-limit risk.
        """
        if not self._logged_in:
            log.warning("Not logged in -- search results may be limited.")

        for page in range(1, max_pages + 1):
            params = {
                "keywords" : query,
                "origin"   : "GLOBAL_SEARCH_HEADER",
                "page"     : page,
            }
            log.info("Fetching search page %d / %d ...", page, max_pages)

            for attempt in range(1, MAX_RETRIES + 1):
                try:
                    resp = self.session.get(
                        SEARCH_URL, params=params, timeout=20
                    )
                    resp.raise_for_status()
                    break
                except requests.RequestException as exc:
                    log.warning(
                        "Page %d fetch attempt %d failed: %s", page, attempt, exc
                    )
                    if attempt == MAX_RETRIES:
                        log.error("Giving up on page %d.", page)
                        resp = None
                        break
                    time.sleep(random.uniform(MIN_DELAY_SEC, MAX_DELAY_SEC))

            if resp is None:
                continue

            soup  = BeautifulSoup(resp.text, "html.parser")
            cards = soup.find_all(
                "li",
                class_=lambda c: c and "reusable-search__result-container" in c,
            )

            if not cards:
                log.info("No result cards found on page %d -- stopping.", page)
                break

            for card in cards:
                yield card

            delay = random.uniform(MIN_DELAY_SEC, MAX_DELAY_SEC)
            log.debug("Sleeping %.2f s before next page...", delay)
            time.sleep(delay)

    # ------------------------------------------------------------------
    def extract_profile_data(self, card) -> dict:
        """
        Extracts name, headline, location, and profile URL from a search
        result card element. Returns a dict with those fields plus a
        timestamp.  Missing fields default to an empty string.
        """
        data = {
            "name"        : "",
            "headline"    : "",
            "location"    : "",
            "profile_url" : "",
            "scraped_at"  : datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        }

        # Name
        name_tag = card.find(
            "span", attrs={"aria-hidden": "true"}
        )
        if name_tag:
            data["name"] = name_tag.get_text(strip=True)

        # Headline (professional summary line)
        headline_tag = card.find(
            "div",
            class_=lambda c: c and "entity-result__primary-subtitle" in c,
        )
        if headline_tag:
            data["headline"] = headline_tag.get_text(strip=True)

        # Location
        location_tag = card.find(
            "div",
            class_=lambda c: c and "entity-result__secondary-subtitle" in c,
        )
        if location_tag:
            data["location"] = location_tag.get_text(strip=True)

        # Profile URL
        link_tag = card.find("a", href=lambda h: h and "/in/" in h)
        if link_tag:
            href = link_tag["href"]
            # Strip query params from the URL.
            data["profile_url"] = href.split("?")[0]

        return data

    # ------------------------------------------------------------------
    def save_to_csv(self, records: list, output_path: str = OUTPUT_FILE) -> int:
        """
        Writes a list of profile dicts to a CSV file.
        Appends if the file already exists; creates with header if new.
        Returns the number of records written.
        """
        if not records:
            log.warning("No records to save.")
            return 0

        fieldnames = ["name", "headline", "location", "profile_url", "scraped_at"]
        file_exists = os.path.isfile(output_path)

        with open(output_path, "a", newline="", encoding="utf-8") as fh:
            writer = csv.DictWriter(fh, fieldnames=fieldnames)
            if not file_exists:
                writer.writeheader()
            writer.writerows(records)

        log.info("Saved %d records to %s", len(records), output_path)
        return len(records)


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    # Credentials -- store these in environment variables in production.
    LI_USER = os.environ.get("LI_USER", "priya.verma@goldenreturns.example")
    LI_PASS = os.environ.get("LI_PASS", "")

    if not LI_PASS:
        import getpass
        LI_PASS = getpass.getpass("LinkedIn password: ")

    scraper = LinkedInScraper(username=LI_USER, password=LI_PASS)

    if not scraper.login():
        log.error("Login failed. Check credentials. Exiting.")
        raise SystemExit(1)

    log.info("Starting profile search: query='%s'", SEARCH_QUERY)
    collected = []
    for card in scraper.search_profiles(query=SEARCH_QUERY, max_pages=MAX_PAGES):
        profile = scraper.extract_profile_data(card)
        if profile["name"]:          # skip blank result cards
            collected.append(profile)
            if len(collected) % 50 == 0:
                log.info("Collected %d profiles so far...", len(collected))

    total = scraper.save_to_csv(collected, output_path=OUTPUT_FILE)
    log.info("Done. Total profiles saved: %d", total)
'@

        $pyPath = "$destDir\linkedin_scrape.py"
        [System.IO.File]::WriteAllText($pyPath, $pythonScript, [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $pyPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $pyPath"
    } catch {
        $msg = "[$role] Step 3 FAILED (linkedin_scrape.py): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 4. Documents\scraping_scripts\fb_audience_export.json
    # ==================================================================
    Write-SetupLog "[$role] Step 4: fb_audience_export.json"
    try {
        $destDir = "$profileBase\Documents\scraping_scripts"
        New-DirectoryIfMissing $destDir

        # Indian first + last name pools for JSON generation (kept local to this step).
        $fbFirstNames = @(
            'Amit','Rajesh','Suresh','Vikas','Rohit','Deepak','Manoj','Sanjay','Naresh','Harish',
            'Arun','Vinod','Girish','Lalit','Naveen','Yogesh','Kapil','Tarun','Gaurav','Manish',
            'Priya','Sneha','Neha','Pooja','Kavita','Meena','Anita','Rekha','Savita','Nisha',
            'Sunita','Usha','Sharda','Asha','Preeti','Meera','Vandana','Shalini','Swati','Jyoti',
            'Dinesh','Satish','Ashok','Sunil','Bharat','Devendra','Kamal','Hemant','Mukesh','Prakash',
            'Ravi','Mohan','Ramesh','Rajendra','Pramod','Srikant','Vivek','Alok','Sandeep','Nikhil',
            'Ankita','Ritu','Divya','Pallavi','Shruti','Anjali','Mamta','Geeta','Radha','Sulekha',
            'Suman','Poonam','Kamla','Sarla','Nirmala','Lata','Madhuri','Pushpa','Kiran','Seema',
            'Sachin','Rahul','Arjun','Varun','Kunal','Siddharth','Akshay','Abhishek','Nitin','Pankaj'
        )
        $fbLastNames = @(
            'Sharma','Verma','Patel','Gupta','Singh','Joshi','Mehta','Shah','Agarwal','Mishra',
            'Tiwari','Pandey','Yadav','Jain','Bose','Reddy','Rao','Nair','Iyer','Menon',
            'Thomas','George','Naidu','Gowda','Kamath','Shetty','Pawar','Desai','Kulkarni','Patil',
            'Jadhav','Sawant','Gaikwad','Mane','Kadam','Shinde','Chavan','Thakur','Rawat','Bisht',
            'Chauhan','Rajput','Dixit','Tripathi','Srivastava','Dubey','Shukla','Saxena','Bajpai','Lal',
            'Sinha','Kumar','Banerjee','Chatterjee','Mukherjee','Das','Pillai','Nambiar','Hegde','Deshpande',
            'More','Bhosale','Wagh','Negi','Misra','Awasthi','Asthana','Dixit','Pandya','Trivedi'
        )
        $fbCities  = @('Mumbai','Delhi','Bangalore','Hyderabad','Chennai','Pune')
        $fbIncomes = @('5L-10L','10L-20L','20L-50L','2L-5L')

        # Seeded RNG for deterministic output (different seed from global to keep
        # this data set independent but reproducible).
        $fbRng = New-Object System.Random(7919)

        $sb = [System.Text.StringBuilder]::new()
        [void]$sb.Append('[')

        for ($i = 1; $i -le 500; $i++) {
            $firstName = $fbFirstNames[$fbRng.Next(0, $fbFirstNames.Count)]
            $lastName  = $fbLastNames[$fbRng.Next(0, $fbLastNames.Count)]
            $name      = "$firstName $lastName"
            # Phone: starts with 9, then 9 random digits.
            $phone     = '9' + ($fbRng.Next(100000000, 999999999)).ToString()
            $income    = $fbIncomes[$fbRng.Next(0, $fbIncomes.Count)]
            $city      = $fbCities[$fbRng.Next(0, $fbCities.Count)]
            $ageMin    = @(25,30,35,40,45)[$fbRng.Next(0, 5)]
            $ageMax    = $ageMin + 10
            $ageRange  = "$ageMin-$ageMax"

            # JSON-escape the name (names here are ASCII-safe, but guard quotes).
            $nameEsc   = $name   -replace '"', '\"'
            $cityEsc   = $city   -replace '"', '\"'
            $incomeEsc = $income -replace '"', '\"'

            $entry = ('{"id":%d,"name":"%s","phone":"%s","interest_tag":"investment","estimated_income":"%s","age_range":"%s","city":"%s"}' -f `
                $i, $nameEsc, $phone, $incomeEsc, $ageRange, $cityEsc)

            if ($i -lt 500) {
                [void]$sb.AppendLine($entry + ',')
            } else {
                [void]$sb.AppendLine($entry)
            }
        }

        [void]$sb.Append(']')

        $jsonPath = "$destDir\fb_audience_export.json"
        [System.IO.File]::WriteAllText($jsonPath, $sb.ToString(), [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $jsonPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $jsonPath (500 entries)"
    } catch {
        $msg = "[$role] Step 4 FAILED (fb_audience_export.json): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 5. Documents\CRM_Leads_Export_2026-04-17.csv
    # ==================================================================
    Write-SetupLog "[$role] Step 5: CRM_Leads_Export_2026-04-17.csv"
    try {
        $destDir = "$profileBase\Documents"
        New-DirectoryIfMissing $destDir

        # First 500 leads that have Status HOT or WARM.
        $hotWarm = @($LeadData | Where-Object { $_.Status -eq 'HOT' -or $_.Status -eq 'WARM' } |
                     Select-Object -First 500)

        $crmPath = "$destDir\CRM_Leads_Export_2026-04-17.csv"
        $hotWarm | Export-Csv -Path $crmPath -NoTypeInformation -Encoding UTF8
        Add-HashRecord -FilePath $crmPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $crmPath ($($hotWarm.Count) rows)"
    } catch {
        $msg = "[$role] Step 5 FAILED (CRM_Leads_Export_2026-04-17.csv): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 6. Chrome History SQLite
    # ==================================================================
    Write-SetupLog "[$role] Step 6: Chrome History"
    try {
        $chromeDir = "$profileBase\AppData\Local\Google\Chrome\User Data\Default"
        New-DirectoryIfMissing $chromeDir

        # Chrome timestamps: microseconds since 1601-01-01 00:00:00 UTC.
        $chromeEpoch = [datetime]::new(1601, 1, 1, 0, 0, 0, [System.DateTimeKind]::Utc)

        function ConvertTo-ChromeTime02 {
            param([string]$DateStr)
            try {
                $dt = [datetime]::Parse($DateStr, $null, [System.Globalization.DateTimeStyles]::AssumeLocal)
                $dt = $dt.ToUniversalTime()
                return [long](($dt - $chromeEpoch).TotalSeconds * 1000000)
            } catch {
                return 13300000000000000  # fallback: approx Apr 2026
            }
        }

        $sqlStatements = [System.Collections.Generic.List[string]]::new()
        $sqlStatements.Add("CREATE TABLE urls (id INTEGER PRIMARY KEY, url TEXT, title TEXT, visit_count INTEGER, typed_count INTEGER, last_visit_time INTEGER, hidden INTEGER);")
        $sqlStatements.Add("CREATE TABLE visits (id INTEGER PRIMARY KEY, url INTEGER, visit_time INTEGER, from_visit INTEGER, transition INTEGER, segment_id INTEGER, visit_duration INTEGER);")
        $sqlStatements.Add("CREATE TABLE meta (key TEXT PRIMARY KEY, value TEXT);")
        $sqlStatements.Add("INSERT INTO meta VALUES ('version','58');")
        $sqlStatements.Add("INSERT INTO meta VALUES ('last_compatible_version','58');")

        if (-not $ChromeUrlHistory_Agent02 -or $ChromeUrlHistory_Agent02.Count -eq 0) {
            Write-SetupLog "WARNING: `$ChromeUrlHistory_Agent02 is empty -- skipping Chrome History for AGENT-02" -Level WARN
        } else {
            $visitId = 1
            for ($u = 0; $u -lt $ChromeUrlHistory_Agent02.Count; $u++) {
                $row    = $ChromeUrlHistory_Agent02[$u]
                $urlId  = $u + 1
                $chrTs  = ConvertTo-ChromeTime02 -DateStr $row.LastVisit
                $urlEsc = $row.Url   -replace "'", "''"
                $ttlEsc = $row.Title -replace "'", "''"
                $sqlStatements.Add("INSERT INTO urls VALUES ($urlId,'$urlEsc','$ttlEsc',$($row.VisitCount),0,$chrTs,0);")
                $sqlStatements.Add("INSERT INTO visits VALUES ($visitId,$urlId,$chrTs,0,805306368,0,0);")
                $visitId++
            }
        }

        $historyPath = "$chromeDir\History"
        $ok = New-SqliteDb -DbPath $historyPath -SqlStatements $sqlStatements.ToArray()
        if ($ok) {
            Add-HashRecord -FilePath $historyPath -Role $role
            $filesCreated++
            Write-SetupLog "[$role] Created: $historyPath"
        } else {
            $errors.Add("[$role] Step 6: New-SqliteDb returned false for Chrome History (sqlite3 unavailable?)")
        }
    } catch {
        $msg = "[$role] Step 6 FAILED (Chrome History): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 7. Sticky Notes SQLite (plum.sqlite)
    # ==================================================================
    Write-SetupLog "[$role] Step 7: Sticky Notes plum.sqlite"
    try {
        $stickyDir = "$profileBase\AppData\Local\Packages\Microsoft.MicrostickyNotes_8wekyb3d8bbwe\LocalState"
        New-DirectoryIfMissing $stickyDir

        $stickySchema = @(
            "CREATE TABLE Note (" +
                "id TEXT PRIMARY KEY, " +
                "dc TEXT, " +
                "windowPosition TEXT, " +
                "IsOpen INTEGER, " +
                "IsAlwaysOnTop INTEGER, " +
                "CreationNoteIdAnchor TEXT, " +
                "Theme INTEGER, " +
                "IsFutureNote INTEGER, " +
                "RemoteId TEXT, " +
                "ChangeKey TEXT, " +
                "LastServerVersion TEXT, " +
                "RemoteSchemaVersion INTEGER, " +
                "IsRemoteDataInvalid INTEGER, " +
                "HasAttachment INTEGER, " +
                "Type INTEGER, " +
                "IsCreatedBySync INTEGER, " +
                "IsSyncingNote INTEGER, " +
                "IsDeleted INTEGER, " +
                "[Text] TEXT" +
            ");",

            "INSERT INTO Note VALUES (" +
                "'note-001'," +
                "'2026-04-17T09:15:00Z'," +
                "'{""top"":100,""left"":200,""height"":300,""width"":250}'," +
                "1," +
                "0," +
                "NULL," +
                "0," +
                "0," +
                "NULL," +
                "NULL," +
                "NULL," +
                "0," +
                "0," +
                "0," +
                "0," +
                "0," +
                "0," +
                "0," +
                "'Leads target: 500 HOT leads by EOM. Ask Arjun for LinkedIn budget approval. Vikas to fix scraper timeout.'" +
            ");"
        )

        $plumPath = "$stickyDir\plum.sqlite"
        $ok = New-SqliteDb -DbPath $plumPath -SqlStatements $stickySchema
        if ($ok) {
            Add-HashRecord -FilePath $plumPath -Role $role
            $filesCreated++
            Write-SetupLog "[$role] Created: $plumPath"
        } else {
            $errors.Add("[$role] Step 7: New-SqliteDb returned false for plum.sqlite (sqlite3 unavailable?)")
        }
    } catch {
        $msg = "[$role] Step 7 FAILED (plum.sqlite): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # 8. Desktop\Daily_Target.txt
    # ==================================================================
    Write-SetupLog "[$role] Step 8: Daily_Target.txt"
    try {
        $destDir = "$profileBase\Desktop"
        New-DirectoryIfMissing $destDir

        $targetContent = @"
Daily Target -- Apr 17, 2026
Leads to process: 200
HOT leads generated today: 47
Assigned to closers: 23
Pending assignment: 24
--- Arjun
"@

        $targetPath = "$destDir\Daily_Target.txt"
        [System.IO.File]::WriteAllText($targetPath, $targetContent, [System.Text.Encoding]::UTF8)
        Add-HashRecord -FilePath $targetPath -Role $role
        $filesCreated++
        Write-SetupLog "[$role] Created: $targetPath"
    } catch {
        $msg = "[$role] Step 8 FAILED (Daily_Target.txt): $($_.Exception.Message)"
        Write-SetupLog $msg 'ERROR'
        $errors.Add($msg)
    }

    # ==================================================================
    # Summary
    # ==================================================================
    $summary = @{
        Role         = $role
        FilesCreated = $filesCreated
        Errors       = $errors.ToArray()
    }

    Write-SetupLog ("[$role] Invoke-RoleSetup complete -- files created: $filesCreated, errors: $($errors.Count)")
    return $summary
}
