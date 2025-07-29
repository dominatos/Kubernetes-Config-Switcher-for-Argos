# 💪 Kubernetes Config Switcher for Argos

A convenient [Argos](https://github.com/p-e-w/argos) script to quickly switch between multiple Kubernetes config files directly from your Linux desktop panel — with support for `k9s` and system notifications.

---

## 📦 Features

- Shows the current active Kubernetes cluster.
- Lists all other available configs in `~/.kube/config-*`.
- Allows one-click switching between them.
- Supports launching `k9s` in a terminal.
- Uses `notify-send` for user feedback.

---

## 📁 File Structure

```bash
~/.kube/
├── config                  # Active kubeconfig
├── config-dev             # Inactive config
└── config-prod            # Another inactive config
```

---

## 💠 Installation

1. **Install Argos** (if not already):

   ```bash
   sudo apt install gir1.2-gtk-3.0 jq xclip libnotify-bin
   git clone https://github.com/p-e-w/argos.git
   cd argos
   ./install.sh
   ```

2. **Install dependencies**:

   - `notify-send`
   - Optional: `k9s`, `gnome-terminal`, `xterm`, etc.

3. **Install the script**: Save it as:

   ```bash
   ~/.config/argos/k8s-config.30s.sh
   ```

4. **Make it executable**:

   ```bash
   chmod +x ~/.config/argos/k8s-config.30s.sh
   ```

---

## 🚀 Usage

The Argos dropdown menu will display:

- The current context name from `~/.kube/config`.
- A list of other `config-*` files for quick switching.
- A button to launch `k9s` in a new terminal.
- A shortcut to open `~/.kube` folder in the file manager.

Clicking a config item will:

- Move the current `config` to a file named `config-<clustername>`
- Activate the selected config by renaming it to `config`
- Show a system notification with the name of the new cluster

---

## 📂 Example Output

```
🔧 K8s: dev-cluster
------------------
✅ dev-cluster (active)
------------------
Available Configs:
🔄 prod-cluster | click to switch
🔄 staging | click to switch
------------------
🚀 Open k9s
📁 Open ~/.kube
🔄 Refresh
```

---

## 💡 Tips

- You can rename any kubeconfig file manually:

  ```bash
  mv ~/.kube/config ~/.kube/config-dev
  cp ~/.kube/config-prod ~/.kube/config
  ```

- If `current-context` is missing, the script falls back to the first available context.

---

## 📜 License

MIT — feel free to use, modify, and share.

---

## ✍️ Author

[Sviatoslav](https://github.com/dominatos)

