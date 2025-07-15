
 <div style="display:flex;justify-content:center">
  <h1> Bhilaipedia Deployment Documentation</h1>
  <ul>
</div>


## Table of Contents
1. [Deployment Overview](#deployment-overview)
2. [Database Configuration](#database-configuration)
3. [MediaWiki Service](#mediawiki-service)
4. [Extensions](#extensions)
   - [Editors](#editors)
   - [Parser Hooks](#parser-hooks)
   - [Other Extensions](#other-extensions)
5. [Skins](#skins)
6. [Template Boxes and Gadgets](#template-boxes-and-gadgets)
7. [Services and Entry Points](#services-and-entry-points)

## Deployment Overview

This MediaWiki instance is deployed using Docker containers with the following components:
- MySQL 5.7 database
- MediaWiki with PHP 8.1.32
- Persistent storage for both database and wiki content

## Database Configuration

```yaml
database:
  image: mysql:5.7
  environment:
    MYSQL_DATABASE: bhilaipedia
    MYSQL_USER: bhilaipedia
    MYSQL_PASSWORD: bhilaipedia
    MYSQL_ROOT_PASSWORD: bhilaipedia
  volumes:
    - ./mysql_data:/var/lib/mysql
```

**Configuration Details:**
- Database name: `bhilaipedia`
- User: `bhilaipedia` with password `bhilaipedia`
- Root password: `bhilaipedia`
- Data persistence: MySQL data is stored in `./mysql_data` on the host

## MediaWiki Service

```yaml
mediawiki:
  image: mediawiki
  ports:
    - 8080:80
  links:
    - database
  volumes:
    - ./mediawiki_data:/var/www/html/images
    - ./LocalSettings.php:/var/www/html/LocalSettings.php
    - ./extensions/PageOwnership:/var/www/html/extensions/PageOwnership
```

**Configuration Details:**
- Accessible on port 8080 (mapped to container port 80)
- Linked to the MySQL database service
- Persistent storage:
  - Uploaded images stored in `./mediawiki_data`
  - Custom configuration in `LocalSettings.php`
  - Custom PageOwnership extension mounted from host

## Extensions

### Editors

**VisualEditor**
- License: MIT
- Description: Visual editor for MediaWiki
- Authors: Alex Monk, Bartosz Dziewoński, and others
- Provides WYSIWYG editing interface

### Parser Hooks

**PageOwnership**
- Version: 1.2.2
- License: GPL-2.0-or-later
- Author: thomas-topway-it
- Description: Implements page ownership based on users and groups through a user-friendly interface
- Custom extension mounted from host

**ParserFunctions**
- Version: 1.6.1
- License: GPL-2.0-or-later
- Authors: Tim Starling, Robert Rohde, and others
- Description: Enhances parser with logical functions
- Provides additional parser functions for templates

### Other Extensions

**Gadgets**
- License: GPL-2.0-or-later
- Authors: Daniel Kinzler, Max Semenik, and others
- Description: Lets users select custom CSS and JavaScript gadgets in their preferences
- Enables user-customizable interface elements

**MultimediaViewer**
- License: GPL-2.0-or-later
- Authors: Gergő Tisza, Gilles Dubuc, and others
- Description: Expands thumbnails in a larger size in a fullscreen interface
- Provides enhanced media viewing experience

## Skins

**Timeless**
- Version: 0.9.1
- License: GPL-2.0-or-later
- Author: Isarra Yos
- Description: A timeless skin designed after the Winter prototype by Brandon Harris, and various styles by the Wikimedia Foundation
- Responsive design that works well on all devices

## Template Boxes and Gadgets

The Gadgets extension allows for the creation of custom user interface elements:
- Users can enable/disable gadgets in their preferences
- Gadgets can include:
  - Custom JavaScript enhancements
  - CSS styling modifications
  - Additional interface components

To create new gadgets:
1. Add gadget definitions to `MediaWiki:Gadgets-definition`
2. Create corresponding JavaScript/CSS pages in the `MediaWiki:` namespace
3. Users can then select gadgets in their preferences

## Services and Entry Points

**System Information:**
- MediaWiki Version: 1.43.1
- PHP Version: 8.1.32 (apache2handler)
- ICU Version: 72.1
- MySQL Version: 5.7.44

**Entry Point URLs:**
- Article path: `/index.php/$1`
- Script path: `/`
- API endpoint: `/api.php`
- REST endpoint: `/rest.php` 

## Key Features & Access Points

### 1. PageOwnership Extension
**Purpose**: Controls page editing permissions based on ownership  
**Access Points**:
- Special:PageOwnership - `http://localhost:8080/index.php/Special:PageOwnership`
- Management Interface - `http://localhost:8080/index.php/Special:PageOwnershipAdmin`

**Key Functions**:
- Assign owners to pages
- Restrict edits to owners/groups
- Configure inheritance rules

---

### 2. Gadgets System
**Access Points**:
- Gadget definitions - `http://localhost:8080/index.php/MediaWiki:Gadgets-definition`
- User preferences - `http://localhost:8080/index.php/Special:Preferences#mw-prefsection-gadgets`

**Example Gadget Setup**:
1. Define in Gadgets-definition:
   ```mediawiki
   * MyTool[ResourceLoader|default]|mytool.js|mytool.css
   ```
2. Create JS/CSS pages:
   - `http://localhost:8080/index.php/MediaWiki:Gadget-mytool.js`
   - `http://localhost:8080/index.php/MediaWiki:Gadget-mytool.css`

---

### 3. Template System
**Infobox Template Example**:
```mediawiki
{{Infobox_Institute
| name = 
| logo = 
| established = 
| type = 
}}
```
**Access Points**:
- Template page - `http://localhost:8080/index.php/Template:Infobox_Institute`
- Template documentation - `http://localhost:8080/index.php/Template:Infobox_Institute/doc`

---

### 4. Media Management
**Access Points**:
- File upload - `http://localhost:8080/index.php/Special:Upload`
- File list - `http://localhost:8080/index.php/Special:NewFiles`
- Media search - `http://localhost:8080/index.php/Special:MediaSearch`

---

## Essential Extensions

| Extension       | Purpose                          | Access Point |
|-----------------|----------------------------------|--------------|
| VisualEditor    | WYSIWYG editing                 | Available on all edit pages |
| ParserFunctions | Enhanced template logic         | Automatically available in templates |
| MultimediaViewer| Enhanced media display          | Activates when viewing images |

---

## Skin Configuration
**Timeless Skin**:
- Mobile-responsive design
- Customization: `http://localhost:8080/index.php/MediaWiki:Timeless.css`

---

## API Endpoints
- Main API: `http://localhost:8080/api.php`
- REST API: `http://localhost:8080/rest.php`
- Action API docs: `http://localhost:8080/index.php/Special:ApiHelp`
 
This documentation provides a comprehensive overview of the Bhilaipedia deployment, its configuration, and the extensions that enhance its functionality. For additional customization, refer to the specific extension documentation and MediaWiki's official manuals.