# Configuration
$BACKUP_DIR = ".\backups"
$TIMESTAMP = Get-Date -Format "yyyyMMdd_HHmmss"
$DB_CONTAINER = "bhilaipedia-database-1"

# Create backup directory
New-Item -ItemType Directory -Force -Path $BACKUP_DIR | Out-Null

# 1. Database Backup
docker exec $DB_CONTAINER mysqldump -u root -pbhilaipedia bhilaipedia | Out-File -FilePath "$BACKUP_DIR\db_$TIMESTAMP.sql" -Encoding UTF8

# 2. Files Backup with retry logic
$FilesToBackup = @(
    ".\mediawiki_data",
    ".\extensions",
    ".\database_backup.sql", 
    ".\LocalSettings.php"
)

$tempDir = "$env:TEMP\wiki_backup_$TIMESTAMP"
New-Item -ItemType Directory -Path $tempDir | Out-Null

try {
    # Copy files to temp directory
    Copy-Item $FilesToBackup -Destination $tempDir -Recurse -Force
    
    # Zip with retry
    $zipPath = "$BACKUP_DIR\wiki_files_$TIMESTAMP.zip"
    $retryCount = 3
    $retryDelay = 2
    
    do {
        try {
            Add-Type -Assembly "System.IO.Compression.FileSystem"
            [IO.Compression.ZipFile]::CreateFromDirectory(
                $tempDir,
                $zipPath,
                [IO.Compression.CompressionLevel]::Optimal,
                $false
            )
            break
        } catch {
            $retryCount--
            if ($retryCount -eq 0) { throw }
            Start-Sleep -Seconds $retryDelay
        }
    } while ($retryCount -gt 0)
} finally {
    # Cleanup temp files
    Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
}
 