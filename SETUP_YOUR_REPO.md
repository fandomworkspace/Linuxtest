# Adding KDE Plasma Desktop to Your Linuxtest Repository

Complete step-by-step guide to add the KDE Plasma setup to `https://github.com/fandomworkspace/Linuxtest`

---

## 🚀 Quickest Method (Automated)

### Step 1: Clone Your Repository

```bash
# Clone your Linuxtest repository
git clone https://github.com/fandomworkspace/Linuxtest.git
cd Linuxtest
```

### Step 2: Download the Setup Script

Download `setup-repo.sh` from the files provided and save it in your repository root:

```bash
# The script should be in your Linuxtest/ directory
chmod +x setup-repo.sh
```

### Step 3: Run the Script

```bash
# Run from the repository root
bash setup-repo.sh
```

The script will:
- ✅ Create `.devcontainer/` directory
- ✅ Add all configuration files
- ✅ Create all shell scripts
- ✅ Set proper permissions
- ✅ Generate Docker configuration

### Step 4: Verify Files

```bash
# Check what was created
git status

# You should see:
# .devcontainer/devcontainer.json
# .devcontainer/Dockerfile
# .devcontainer/setup-kde-desktop.sh
# .devcontainer/start-kde-desktop.sh
# .devcontainer/vnc-startup.sh
# .devcontainer/supervisord.conf
# .devcontainer/.dockerignore
# .devcontainer/.gitignore
# .devcontainer/README.md
# .devcontainer/docker-compose.yml
```

### Step 5: Commit and Push

```bash
# Add all .devcontainer files
git add .devcontainer/

# Commit with a meaningful message
git commit -m "Add KDE Plasma desktop Codespaces environment"

# Push to GitHub
git push origin main
```

### Step 6: Create Your First Codespace

1. Go to: **https://github.com/fandomworkspace/Linuxtest**
2. Click **Code** (green button)
3. Click **Codespaces** tab
4. Click **Create codespace on main**
5. Wait for container to build (2-3 minutes)

### Step 7: Access Your Desktop

Once Codespace is open:

1. Click the **Ports** tab at the bottom of VS Code
2. Look for **Port 6080** (labeled "KDE Plasma Desktop (noVNC)")
3. Click the **globe icon** 🌐 next to it
4. Browser opens with your desktop!
5. Click inside the noVNC window
6. You now have a full KDE Plasma desktop! 🎉

---

## 📝 Manual Method (If Automated Fails)

If you prefer to set up manually or the script doesn't work:

### Step 1: Clone Repository

```bash
git clone https://github.com/fandomworkspace/Linuxtest.git
cd Linuxtest
```

### Step 2: Create Directory Structure

```bash
mkdir -p .devcontainer
cd .devcontainer
```

### Step 3: Copy Files

Copy these files into `.devcontainer/`:

From the provided downloads:
- `devcontainer.json`
- `Dockerfile`
- `setup-kde-desktop.sh`
- `start-kde-desktop.sh`
- `vnc-startup.sh`
- `supervisord.conf`
- `.dockerignore`
- `.gitignore`
- `README.md` (rename from provided README.md to avoid conflict)
- `docker-compose.yml`

### Step 4: Make Scripts Executable

```bash
chmod +x setup-kde-desktop.sh
chmod +x start-kde-desktop.sh
chmod +x vnc-startup.sh
```

### Step 5: Verify Structure

```bash
# From Linuxtest root directory
ls -la .devcontainer/

# Should show:
# .dockerignore
# .gitignore
# Dockerfile
# README.md
# devcontainer.json
# docker-compose.yml
# setup-kde-desktop.sh
# start-kde-desktop.sh
# supervisord.conf
# vnc-startup.sh
```

### Step 6: Commit and Push

```bash
git add .devcontainer/
git commit -m "Add KDE Plasma desktop Codespaces environment"
git push origin main
```

---

## ✅ Verification Checklist

After setup, verify everything:

```bash
# Check files exist
test -f .devcontainer/devcontainer.json && echo "✓ devcontainer.json"
test -f .devcontainer/Dockerfile && echo "✓ Dockerfile"
test -f .devcontainer/setup-kde-desktop.sh && echo "✓ setup-kde-desktop.sh"
test -f .devcontainer/start-kde-desktop.sh && echo "✓ start-kde-desktop.sh"
test -f .devcontainer/vnc-startup.sh && echo "✓ vnc-startup.sh"

# Check scripts are executable
test -x .devcontainer/setup-kde-desktop.sh && echo "✓ setup-kde-desktop.sh executable"
test -x .devcontainer/start-kde-desktop.sh && echo "✓ start-kde-desktop.sh executable"
test -x .devcontainer/vnc-startup.sh && echo "✓ vnc-startup.sh executable"

# Verify JSON syntax
python3 -m json.tool .devcontainer/devcontainer.json > /dev/null && echo "✓ devcontainer.json valid"
```

---

## 🧪 Test Locally (Optional)

Before pushing to GitHub, you can test locally with Docker:

### Prerequisites
- Docker installed
- Docker Compose installed

### Run Test

```bash
cd .devcontainer

# Build and start container
docker-compose up -d

# Wait 30 seconds for services to start
sleep 30

# Check if services are running
docker-compose exec kde-desktop bash /tmp/health-check.sh

# Access desktop at http://localhost:6080
# Open browser and go to: http://localhost:6080/vnc.html

# Stop when done
docker-compose down
```

---

## 🔍 What Each File Does

| File | Purpose |
|------|---------|
| `devcontainer.json` | GitHub Codespaces configuration (REQUIRED) |
| `Dockerfile` | Container image definition (REQUIRED) |
| `setup-kde-desktop.sh` | One-time setup script (REQUIRED) |
| `start-kde-desktop.sh` | Service startup script (REQUIRED) |
| `vnc-startup.sh` | VNC helper script (REQUIRED) |
| `supervisord.conf` | Service management config (optional) |
| `.dockerignore` | Docker build optimization (optional) |
| `.gitignore` | Git ignore rules (optional) |
| `README.md` | Quick reference guide (optional) |
| `docker-compose.yml` | Local testing config (optional) |

---

## 🎯 Using Your Desktop in Codespace

Once your Codespace is running:

### File Management
- Open **Dolphin** to browse files in `/home/vscode/`
- Drag and drop files from the browser
- Right-click for context menu

### Terminal Access
Two options:
1. **Konsole** - Click in desktop and launch Konsole
2. **VS Code Terminal** - Use the built-in terminal (doesn't need desktop)

### Web Browsing
- Click **Firefox** on the desktop
- Browse normally

### Text Editing
- **Kate** for GUI editing
- **VS Code** terminal for CLI editing

### Development
- Use any application installed in KDE
- Full Linux environment available
- All standard tools pre-installed

---

## 🚨 Troubleshooting

### Desktop Won't Load

**Check if services are running:**
```bash
bash /tmp/health-check.sh
```

**View logs:**
```bash
tail -50 /tmp/vncserver.log
tail -50 /tmp/websockify.log
```

**Restart services:**
```bash
pkill -f Xvfb
pkill -f vncserver
pkill -f websockify
sleep 2
bash /tmp/start-kde-desktop.sh
```

### Port 6080 Not Showing

1. Wait 30 seconds after Codespace opens
2. Click the **Ports** tab
3. If still not showing, check VS Code output
4. Try refreshing the browser

### High CPU/Memory

1. Close unused applications
2. Restart Codespace (Stop → Start)
3. Check Firefox memory usage
4. Use VS Code terminal instead of desktop for some tasks

### Can't Type in Desktop

1. Click inside the desktop window to focus it
2. Try again
3. Check keyboard layout: Settings → Input Devices

### Files Not Showing in Dolphin

1. Open Dolphin
2. Press Ctrl+L to show location bar
3. Type: `/home/vscode`
4. Press Enter

---

## 📚 Documentation

After setup, refer to:

| Need | Read |
|------|------|
| Quick start | `.devcontainer/README.md` |
| Full guide | Downloaded `README.md` |
| Architecture | Downloaded `ARCHITECTURE.md` |
| Installation help | Downloaded `INSTALLATION.md` |
| File reference | Downloaded `FILE_MANIFEST.md` |
| Quick tips | Downloaded `QUICKSTART.md` |

---

## 🔐 Security Notes

Your setup is private:
- ✅ Only you can access your Codespace
- ✅ GitHub authentication required
- ✅ Port 6080 is localhost only
- ✅ VNC traffic encrypted via HTTPS
- ✅ No data leaves your container

---

## 💡 Tips & Tricks

### Change VNC Password

Edit `Dockerfile` before pushing:

```dockerfile
# Find this line:
RUN echo "codespaces" | vncpasswd -f > /home/vscode/.vnc/passwd

# Change to:
RUN echo "your-new-password" | vncpasswd -f > /home/vscode/.vnc/passwd
```

### Change Resolution

Edit `start-kde-desktop.sh`:

```bash
# Find: -geometry 1920x1080
# Change to: -geometry 1280x720
# Or: -geometry 1024x768
```

### Add More Applications

Edit `Dockerfile`:

```dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends \
    # ... existing packages ...
    vlc \
    libreoffice \
    gimp
```

### Keep Codespace Running Longer

In `.devcontainer/devcontainer.json`:

```json
{
  "postStartCommand": "bash /tmp/start-kde-desktop.sh",
  "remoteEnv": {
    "GITHUBCODESPACE_TIMEOUT_MINUTES": "240"
  }
}
```

---

## ⏱️ Timeline

**First Codespace Creation:**
- Container build: ~2-3 minutes
- Service startup: ~30 seconds
- Total: ~3 minutes
- Desktop ready: After port 6080 opens

**Subsequent Codespaces:**
- Container start: ~30 seconds
- Service startup: ~30 seconds
- Total: ~1 minute
- Desktop ready: Very quick

---

## 📞 Need Help?

### Common Questions

**Q: How do I upload files?**
A: Use Dolphin file manager or VS Code's file explorer

**Q: Can I use this with my own Dockerfile?**
A: Yes, extend the provided Dockerfile with your content

**Q: Does the desktop persist between restarts?**
A: Yes, your files are preserved. `.devcontainer/` controls setup.

**Q: Can I run a server/application?**
A: Yes, any Linux application can run in this environment

**Q: How long does a Codespace last?**
A: Default 30 minutes of inactivity. Can be configured.

---

## ✨ Next Steps

1. ✅ Run setup script or copy files manually
2. ✅ Commit and push to GitHub
3. ✅ Create a Codespace
4. ✅ Open port 6080
5. ✅ Start using your desktop!

---

**You're all set!** Your repository now has a complete KDE Plasma desktop environment. 🚀

For the full experience and more details, read the comprehensive documentation files included.
