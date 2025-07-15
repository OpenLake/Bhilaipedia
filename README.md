 <div style="display:flex;justify-content:center">
  <h1>Bhilaipedia</h1>
  <ul>
</div>

Bhilaipedia is a collaborative knowledge platform powered by **MediaWiki** and **MySQL**, containerized using **Docker**. This project includes an initial SQL backup, allowing you to restore and continue development instantly.


## Documentations: [Link](/Docs/docs.md)

---

## 🐳 Tech Stack

* **MediaWiki** (official Docker image)
* **MySQL 5.7**
* **Docker** + **Docker Compose**

---

## 📁 Project Structure

```
bhilaipedia/
├── docker-compose.yml
├── mediawiki_data/               # MediaWiki uploads
├── mysql_data/                   # MySQL persistent data
├── LocalSettings.php             # MediaWiki configuration (after setup)
└── database_backup.sql.gz        # 🔁 Pre-existing database backup (IMPORTANT)
```

---

## 🚀 Installation Guide

### 🐧 Linux (Ubuntu)

1. **Install Docker & Docker Compose**

```bash
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose
sudo usermod -aG docker $USER
```

2. **Set Up Project**

```bash
mkdir bhilaipedia
cd bhilaipedia
nano docker-compose.yml
```

Paste the following:

```yaml
services:
  database:
    image: mysql:5.7
    environment:
      MYSQL_DATABASE: bhilaipedia
      MYSQL_USER: bhilaipedia
      MYSQL_PASSWORD: bhilaipedia
      MYSQL_ROOT_PASSWORD: bhilaipedia
    volumes:
      - ./mysql_data:/var/lib/mysql

  mediawiki:
    image: mediawiki
    ports:
      - 8080:80
    links:
      - database
    volumes:
      - ./mediawiki_data:/var/www/html/images
#      - ./LocalSettings.php:/var/www/html/LocalSettings.php  # Uncomment later
```

3. **Start Services & Load Database**

```bash
docker-compose up -d
```

Wait 10–20 seconds for MySQL to initialize, then load the **existing backup**:

```bash
gunzip -c database_backup.sql.gz | \
  docker exec -i $(docker ps -qf "name=database") \
  mysql -u root -pbhilaipedia bhilaipedia
```

4. **Finish MediaWiki Setup in Browser**

Visit: [http://localhost:8080](http://localhost:8080)

* DB host: `database`
* DB name: `bhilaipedia`
* DB user: `bhilaipedia`
* DB password: `bhilaipedia`

5. **Configure LocalSettings.php**

* Download `LocalSettings.php` after setup
* Save it to the project root
* Uncomment the corresponding line in `docker-compose.yml`:

```yaml
- ./LocalSettings.php:/var/www/html/LocalSettings.php
```

Then restart services:

```bash
docker-compose down
docker-compose up -d
```

---

### 🪟 Windows

1. **Install [Docker Desktop](https://www.docker.com/products/docker-desktop/)**

2. **Create Project Folder**

```powershell
mkdir bhilaipedia
cd bhilaipedia
notepad docker-compose.yml
```

Paste the same YAML above.

3. **Start Containers and Restore DB**

```powershell
docker-compose up -d
```

Then:

```powershell
gunzip -c database_backup.sql.gz | docker exec -i (docker ps -qf "name=database") `
  mysql -u root -pbhilaipedia bhilaipedia
```

4. Proceed with browser setup and place `LocalSettings.php` as described.

---

## 💾 Backup & Restore

### 📤 To Backup Changes

After any significant edit to the wiki, back it up using:

```bash
win_backup.ps1 # for windows
linux_backup.bash # for linux

```

### 📥 To Restore Again

```bash
gunzip -c database_backup.sql.gz | \
  docker exec -i $(docker ps -qf "name=database") \
  mysql -u root -pbhilaipedia bhilaipedia
```

---

## ✅ Quick Commands

```bash
docker-compose up -d          # Start services
docker-compose down           # Stop services
docker-compose down -v        # Stop and remove volumes
docker ps                     # Show running containers
```

---

## 📄 License

This project uses official open-source images of MediaWiki and MySQL. Please review their respective licenses if deploying commercially.
 