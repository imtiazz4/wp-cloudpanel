# Midnight Commander (mc) – Keyboard Shortcuts Cheat Sheet

A practical reference for **Midnight Commander** shortcuts used when managing files on a Linux server or VPS.

---

# Starting Midnight Commander

Run:

```
mc
```

Exit:

```
F10
```

---

# Navigation

| Key         | Action                 |
| ----------- | ---------------------- |
| `↑ / ↓`     | Move selection         |
| `Enter`     | Open directory or file |
| `Backspace` | Go to parent directory |
| `Tab`       | Switch between panels  |
| `Home`      | Go to first file       |
| `End`       | Go to last file        |
| `Ctrl + \`  | Change directory       |
| `Ctrl + o`  | Show/hide terminal     |

---

# File Operations

| Key   | Action                  |
| ----- | ----------------------- |
| `F3`  | View file               |
| `F4`  | Edit file               |
| `F5`  | Copy file/folder        |
| `F6`  | Move / Rename           |
| `F7`  | Create directory        |
| `F8`  | Delete file/folder      |
| `F9`  | Open top menu           |
| `F10` | Exit Midnight Commander |

---

# File Selection

| Key             | Action                           |
| --------------- | -------------------------------- |
| `Insert`        | Select file                      |
| `+`             | Select files by pattern          |
| `-`             | Unselect files by pattern        |
| `*`             | Invert selection                 |
| `Shift + Arrow` | Multi-select (in some terminals) |

Example patterns:

```
*.zip
*.jpg
*.php
```

---

# Compress Files to ZIP

## Step 1 — Select files

Use:

```
Insert
```

Select multiple files.

---

## Step 2 — Open User Menu

Press:

```
F2
```

---

## Step 3 — Choose Compress

Select:

```
Compress
```

Then choose:

```
zip
```

Example output:

```
archive.zip
```

---

# Extract Archives

Select archive file then press:

```
Enter
```

or use:

```
F2 → Extract
```

Supported formats (if installed):

* zip
* tar
* tar.gz
* tar.bz2
* tar.xz

Install tools if needed:

```
apt install zip unzip tar
```

---

# Copy Selected Files

Select files using `Insert`.

Then press:

```
F5
```

Choose destination panel.

---

# Move Selected Files

Select files then press:

```
F6
```

---

# Rename File

Press:

```
F6
```

Edit name and confirm.

---

# Create Folder

Press:

```
F7
```

Example:

```
backup
```

---

# Delete Files

Select files then press:

```
F8
```

Confirm deletion.

---

# Search Files

Press:

```
Alt + ?
```

Search by:

* file name
* content
* directory

---

# Quick Filter

Press:

```
Ctrl + s
```

Type name to filter list.

---

# Panel Navigation

| Key        | Action                        |
| ---------- | ----------------------------- |
| `Ctrl + u` | Swap panels                   |
| `Ctrl + i` | Sync panels                   |
| `Alt + o`  | Open directory in other panel |

---

# Quick Directory Jump

Open command line in mc and type:

```
cd /var/www
```

Or:

```
Alt + c
```

---

# Useful Locations for VPS

Typical directories:

```
/var/www/
/root/
/home/
/etc/
/var/log/
```

Example for website files:

```
/var/www/domain.com/htdocs
```

---

# Example Workflow (Create Website Backup)

Navigate to site:

```
/var/www/domain.com
```

Select files:

```
Insert
```

Compress:

```
F2 → Compress → zip
```

Result:

```
backup.zip
```

---

# Install Midnight Commander

If not installed:

```
apt install mc
```

Run:

```
mc
```

---

# Summary of Most Important Keys

| Key      | Function      |
| -------- | ------------- |
| `F3`     | View          |
| `F4`     | Edit          |
| `F5`     | Copy          |
| `F6`     | Move / Rename |
| `F7`     | New folder    |
| `F8`     | Delete        |
| `F2`     | User menu     |
| `Insert` | Select files  |
| `F10`    | Exit          |

---

Midnight Commander is one of the most powerful tools for managing files on a Linux server directly from the terminal.
