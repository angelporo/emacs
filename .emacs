(setq user-full-name "mingduo.zj"
      user-mail-address "mingduo.zj@alibaba-inc.com")

(require 'package)
(setq package-archives
      '(("melpa" . "https://raw.githubusercontent.com/d12frosted/elpa-mirror/master/melpa/")
        ("org"   . "https://raw.githubusercontent.com/d12frosted/elpa-mirror/master/org/")
        ("gnu"   . "https://raw.githubusercontent.com/d12frosted/elpa-mirror/master/gnu/")))
(package-initialize)
(setq package-archive-enable-alist '(("melpa" deft magit)))
(unless package-archive-contents (package-refresh-contents))

(dolist (package '(use-package))
   (unless (package-installed-p package)
       (package-install package)))

(use-package exec-path-from-shell
  :ensure
  :custom
  (exec-path-from-shell-check-startup-files nil)
  (exec-path-from-shell-variables '("PATH" "GOPATH" "GOPROXY" "GOPRIVATE"))
  :config
  (when (memq window-system '(mac ns x)) (exec-path-from-shell-initialize)))

(defvar init-dir (expand-file-name "init" user-emacs-directory))
(mapc 'load (directory-files init-dir t ".*el$"))

; 将 custome 配置放到单独的文件，避免污染本文件。
(shell-command "touch ~/.emacs.d/custom.el")
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file)
(put 'scroll-left 'disabled nil)
