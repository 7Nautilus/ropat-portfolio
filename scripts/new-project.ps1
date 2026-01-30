param()

$ErrorActionPreference = "Stop"

function Prompt-WithDefault {
    param(
        [string]$Message,
        [string]$Default = $null,
        [switch]$AllowEmpty
    )

    $prompt = if ([string]::IsNullOrWhiteSpace($Default)) { $Message } else { "$Message [$Default]" }
    while ($true) {
        $response = Read-Host $prompt
        if ([string]::IsNullOrEmpty($response)) {
            if ($AllowEmpty) {
                return ""
            }
            if (-not [string]::IsNullOrWhiteSpace($Default)) {
                return $Default
            }
        }
        if (-not [string]::IsNullOrWhiteSpace($response)) {
            return $response
        }
        Write-Host "Value required." -ForegroundColor Yellow
    }
}

function Prompt-UntilValid {
    param(
        [string]$Message,
        [string]$Pattern,
        [string]$ErrorMessage,
        [string]$Default = $null
    )

    while ($true) {
        $input = Prompt-WithDefault -Message $Message -Default $Default
        if ($input -match $Pattern) {
            return $input
        }
        Write-Host $ErrorMessage -ForegroundColor Yellow
    }
}

function To-YamlString {
    param([string]$Value)
    if ($null -eq $Value) {
        return '""'
    }
    $escaped = $Value -replace '"', '\"'
    return '"' + $escaped + '"'
}

function Add-Line {
    param(
        [System.Text.StringBuilder]$Builder,
        [int]$IndentLevel,
        [string]$Text
    )
    $indent = ('  ' * $IndentLevel)
    [void]$Builder.AppendLine($indent + $Text)
}

function Add-Block {
    param(
        [System.Text.StringBuilder]$Builder,
        [int]$IndentLevel,
        [string]$Key,
        [string]$Content
    )
    Add-Line -Builder $Builder -IndentLevel $IndentLevel -Text "$Key: |"
    if ([string]::IsNullOrWhiteSpace($Content)) {
        Add-Line -Builder $Builder -IndentLevel ($IndentLevel + 1) -Text "TODO: add content"
        return
    }
    $lines = $Content -split "`n"
    foreach ($line in $lines) {
        Add-Line -Builder $Builder -IndentLevel ($IndentLevel + 1) -Text ($line.TrimEnd())
    }
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot ".." )).Path
$projectDataDir = Join-Path $repoRoot "_data/projects"
$frProjectDir = Join-Path $repoRoot "fr/projects"
$enProjectDir = Join-Path $repoRoot "en/projects"

$slug = Prompt-UntilValid -Message "Slug (kebab-case, e.g. album-cover)" -Pattern '^[a-z0-9-]+$' -ErrorMessage "Use lowercase letters, numbers or dashes only."

$projectFile = Join-Path $projectDataDir "$slug.yml"
if (Test-Path $projectFile) {
    throw "Project data file '$slug.yml' already exists."
}

$projectTitleDefault = $slug.ToUpperInvariant()
$projectTitle = Prompt-WithDefault -Message "Project title (display name)" -Default $projectTitleDefault

$categories = @('music', 'branding', 'animation', 'design')
$category = Prompt-UntilValid -Message "Category (${categories -join '/'})" -Pattern '^(music|branding|animation|design)$' -ErrorMessage "Choose one of: $($categories -join ', ')." -Default $categories[0]

$client = Prompt-WithDefault -Message "Client (optional)" -AllowEmpty

$currentYear = (Get-Date).Year.ToString()
$year = Prompt-UntilValid -Message "Year" -Pattern '^[0-9]{4}$' -ErrorMessage "Enter a 4-digit year." -Default $currentYear

$tools = Prompt-WithDefault -Message "Tools (comma separated, optional)" -AllowEmpty

$featuredInput = Prompt-WithDefault -Message "Featured on homepage? (y/N)" -Default "N"
$featured = if ($featuredInput -match '^(y|yes)$') { $true } else { $false }

$mediaType = Prompt-UntilValid -Message "Media type (image/video)" -Pattern '^(image|video)$' -ErrorMessage "Enter 'image' or 'video'." -Default "image"

$defaultImagePath = "/assets/images/projects/$slug.png"
$imageSrc = Prompt-WithDefault -Message "Thumbnail image path" -Default $defaultImagePath
$mainImage = Prompt-WithDefault -Message "Main media path (press Enter to reuse thumbnail)" -Default $imageSrc

$locales = @('fr', 'en')
$localeData = @{}

foreach ($lang in $locales) {
    $titleDefault = $projectTitle
    $title = Prompt-WithDefault -Message "[$lang] Title" -Default $titleDefault

    $subtitleDefault = "TODO: add subtitle ($lang)"
    $subtitle = Prompt-WithDefault -Message "[$lang] Subtitle (Markdown allowed)" -Default $subtitleDefault

    $description = Prompt-WithDefault -Message "[$lang] Short description" -Default "TODO: add description ($lang)"

    $services = Prompt-WithDefault -Message "[$lang] Services (optional)" -AllowEmpty

    $ariaPrefix = if ($lang -eq 'fr') { 'Voir le projet' } else { 'View the project' }
    $ariaLabel = Prompt-WithDefault -Message "[$lang] aria-label" -Default "$ariaPrefix $projectTitle"

    $imageAlt = Prompt-WithDefault -Message "[$lang] Image alt" -Default "$projectTitle"

    $contextTitleDefault = if ($lang -eq 'fr') { 'Contexte du projet' } else { 'Project Context' }
    $contextTitle = Prompt-WithDefault -Message "[$lang] Context title" -Default $contextTitleDefault

    $contextContentDefault = if ($lang -eq 'fr') { 'TODO: completer le contexte (fr).' } else { 'TODO: add project context (en).' }
    $contextContent = Prompt-WithDefault -Message "[$lang] Context (single line, edit file later for paragraphs)" -Default $contextContentDefault

    $seoTitleDefault = "$title | Ropat"
    $seoTitle = Prompt-WithDefault -Message "[$lang] SEO title" -Default $seoTitleDefault

    $seoDescription = Prompt-WithDefault -Message "[$lang] SEO description" -Default $description

    $canonicalUrlBase = if ($lang -eq 'fr') { "https://ropat.art/fr/projects/$slug.html" } else { "https://ropat.art/en/projects/$slug.html" }
    $canonicalUrl = Prompt-WithDefault -Message "[$lang] Canonical URL" -Default $canonicalUrlBase

    $ogTitle = Prompt-WithDefault -Message "[$lang] Open Graph title" -Default $seoTitle
    $ogDescription = Prompt-WithDefault -Message "[$lang] Open Graph description" -Default $seoDescription
    $ogUrl = Prompt-WithDefault -Message "[$lang] Open Graph URL" -Default $canonicalUrl
    $ogImageDefault = "https://ropat.art" + $imageSrc
    $ogImage = Prompt-WithDefault -Message "[$lang] Open Graph image" -Default $ogImageDefault

    $localeData[$lang] = [ordered]@{
        url = if ($lang -eq 'fr') { "/fr/projects/$slug.html" } else { "/en/projects/$slug.html" }
        aria_label = $ariaLabel
        image_alt = $imageAlt
        title = $title
        subtitle = $subtitle
        description = $description
        services = $services
        context_title = $contextTitle
        context_content = $contextContent
        seo = [ordered]@{
            title = $seoTitle
            description = $seoDescription
            canonical_url = $canonicalUrl
            og_title = $ogTitle
            og_description = $ogDescription
            og_url = $ogUrl
            og_image = $ogImage
        }
    }
}

$builder = New-Object System.Text.StringBuilder
Add-Line -Builder $builder -IndentLevel 0 -Text ("slug: " + $slug)
Add-Line -Builder $builder -IndentLevel 0 -Text ("project_title: " + (To-YamlString $projectTitle))
Add-Line -Builder $builder -IndentLevel 0 -Text ("category: $category")
Add-Line -Builder $builder -IndentLevel 0 -Text ("featured: " + $featured.ToString().ToLowerInvariant())
if (-not [string]::IsNullOrWhiteSpace($client)) {
    Add-Line -Builder $builder -IndentLevel 0 -Text ("client: " + (To-YamlString $client))
}
Add-Line -Builder $builder -IndentLevel 0 -Text ("year: " + (To-YamlString $year))
if (-not [string]::IsNullOrWhiteSpace($tools)) {
    Add-Line -Builder $builder -IndentLevel 0 -Text ("tools: " + (To-YamlString $tools))
}
Add-Line -Builder $builder -IndentLevel 0 -Text ("image_src: " + (To-YamlString $imageSrc))
Add-Line -Builder $builder -IndentLevel 0 -Text ("main_image: " + (To-YamlString $mainImage))
Add-Line -Builder $builder -IndentLevel 0 -Text ("media_type: $mediaType")
Add-Line -Builder $builder -IndentLevel 0 -Text "locales:"

foreach ($lang in $locales) {
    $locale = $localeData[$lang]
    Add-Line -Builder $builder -IndentLevel 1 -Text "$lang:"
    Add-Line -Builder $builder -IndentLevel 2 -Text ("url: " + (To-YamlString $locale.url))
    Add-Line -Builder $builder -IndentLevel 2 -Text ("aria_label: " + (To-YamlString $locale.aria_label))
    Add-Line -Builder $builder -IndentLevel 2 -Text ("image_alt: " + (To-YamlString $locale.image_alt))
    Add-Line -Builder $builder -IndentLevel 2 -Text ("title: " + (To-YamlString $locale.title))
    Add-Line -Builder $builder -IndentLevel 2 -Text ("subtitle: " + (To-YamlString $locale.subtitle))
    Add-Line -Builder $builder -IndentLevel 2 -Text ("description: " + (To-YamlString $locale.description))
    if (-not [string]::IsNullOrWhiteSpace($locale.services)) {
        Add-Line -Builder $builder -IndentLevel 2 -Text ("services: " + (To-YamlString $locale.services))
    }
    Add-Line -Builder $builder -IndentLevel 2 -Text ("context_title: " + (To-YamlString $locale.context_title))
    Add-Block -Builder $builder -IndentLevel 2 -Key "context_content" -Content $locale.context_content
    Add-Line -Builder $builder -IndentLevel 2 -Text "seo:"
    Add-Line -Builder $builder -IndentLevel 3 -Text ("title: " + (To-YamlString $locale.seo.title))
    Add-Line -Builder $builder -IndentLevel 3 -Text ("description: " + (To-YamlString $locale.seo.description))
    Add-Line -Builder $builder -IndentLevel 3 -Text ("canonical_url: " + (To-YamlString $locale.seo.canonical_url))
    Add-Line -Builder $builder -IndentLevel 3 -Text ("og_title: " + (To-YamlString $locale.seo.og_title))
    Add-Line -Builder $builder -IndentLevel 3 -Text ("og_description: " + (To-YamlString $locale.seo.og_description))
    Add-Line -Builder $builder -IndentLevel 3 -Text ("og_url: " + (To-YamlString $locale.seo.og_url))
    Add-Line -Builder $builder -IndentLevel 3 -Text ("og_image: " + (To-YamlString $locale.seo.og_image))
}

$projectYaml = $builder.ToString().TrimEnd()

Set-Content -Path $projectFile -Value $projectYaml -Encoding utf8NoBOM

$newFiles = @($projectFile)

function Write-ProjectPage {
    param(
        [string]$Directory,
        [string]$Lang
    )
    $path = Join-Path $Directory "$slug.html"
    if (Test-Path $path) {
        throw "Project page '$path' already exists."
    }
    $content = @"
---
layout: default
lang: "$Lang"
project_id: "$slug"
---

{% include projects/project-main.html project_id=page.project_id %}
"@
    Set-Content -Path $path -Value $content -Encoding utf8NoBOM
    return $path
}

New-Item -ItemType Directory -Path $frProjectDir -Force | Out-Null
New-Item -ItemType Directory -Path $enProjectDir -Force | Out-Null

$newFiles += Write-ProjectPage -Directory $frProjectDir -Lang 'fr'
$newFiles += Write-ProjectPage -Directory $enProjectDir -Lang 'en'

$indexPath = Join-Path $projectDataDir "index.yml"
if (-not (Test-Path $indexPath)) {
    throw "Missing file: _data/projects/index.yml"
}
$indexLines = Get-Content -Path $indexPath
if ($indexLines -notcontains "  - $slug") {
    Add-Content -Path $indexPath -Value "  - $slug"
    $newFiles += $indexPath
}

Write-Host "Created files:" -ForegroundColor Green
$newFiles | Sort-Object -Unique | ForEach-Object { Write-Host "  $_" }
Write-Host "\nNext steps:" -ForegroundColor Cyan
Write-Host "  - Review $(Split-Path $projectFile -Leaf) to polish texts, add thumbnails or services."
Write-Host "  - Add media assets referenced by the project."
