(require 'package)
(setq package-archives
      '(("elpa" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
        ("elpa-devel" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/gnu-devel/")
        ("melpa" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")
        ("nongnu" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
        ("nongnu-devel" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu-devel/")))
(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))

(setq use-package-verbose t)
(setq use-package-always-ensure t)
(setq use-package-always-demand t)
(setq use-package-compute-statistics t)
(setq use-package-vc-prefer-newest t)

;; 允许升级 Emacs 内置的包。
;;(setq package-install-upgrade-built-in t)

(setq auth-sources '("~/.authinfo.gpg"))
;;(setq auth-source-debug t)

(use-package epa
  :config
  (setq-default
   ;; 缺省使用 email 地址加密。
   epa-file-encrypt-to user-mail-address
   ;; 使用 minibuffer 输入 GPG 密码。
   epa-pinentry-mode 'loopback)

  (require 'epa-file)
  (epa-file-enable))

;; command 作为 Meta 键。
(setq mac-command-modifier 'meta)

;; option 作为 Super 键。
(setq mac-option-modifier 'super)

;; fn 作为 Hyper 键。
(setq ns-function-modifier 'hyper)

;; 关闭容易误操作的按键。
;; s- 表示 Super，S- 表示 Shift, H- 表示 Hyper:
(let ((keys '(
              "s-w"
              "C-z"
              "<mouse-2>"
              "s-k"
              "s-,"
              "s-."
              "s--"
              "s-+"
              "C-<wheel-down>"
              "C-<wheel-up>"
              "C-M-<wheel-down>"
              "C-M-<wheel-up>"
              ;;"<down-mouse-1>"
              ;;"<drag-mouse-1>"
              )))
  (dolist (key keys)
    (global-unset-key (kbd key))))

(setq process-adaptive-read-buffering nil)
(setq read-process-output-max (* 1024 1024 4))

(setq inhibit-compacting-font-caches t)
(setq-default message-log-max t)

;; Garbage Collector Magic Hack, 提升 GC 性能。
(use-package gcmh
  :init
  ;;(setq gcmh-verbose t)
  (setq gcmh-idle-delay 'auto) ;; 缺省 15s
  (setq gcmh-auto-idle-delay-factor 10)
  (setq gcmh-high-cons-threshold (* 32 1024 1024))
  (gcmh-mode 1)
  (gcmh-set-high-threshold))

;;(setq garbage-collection-messages t)
(add-hook 'after-init-hook #'garbage-collect t)

(setq my-coreutils-path "/opt/homebrew/opt/curl/bin/")
(setenv "PATH" (concat my-coreutils-path ":" (getenv "PATH")))
(setq exec-path (cons my-coreutils-path  exec-path))

;; socks5 代理信息。
(setq my/socks-host "127.0.0.1")
(setq my/socks-port 1080)
(setq my/socks-proxy (format "socks5h://%s:%d" my/socks-host my/socks-port))

;; 不经过 socks 代理的 CIDR 或域名列表, 需要同时满足 socks-noproxy 和 NO_RROXY 值要求:
;; + socks-noproxy: 域名是正则表达式, 如 \\.baidu.com;
;; + NO_PROXY: 域名支持 *.baidu.com 或 baidu.com;
;; 所以这里使用的是同时满足两者的域名后缀形式, 如 .baidu.com;
(setq my/no-proxy
      '(
        "127.0.0.1/32"
        "10.0.0.0/8"
        "172.0.0.0/8"
        "0.0.0.0/32"
        "localhost"
        "192.168.0.0/16"
        ".cn"
        ".alibaba-inc.com"
        ".taobao.com"
        ".antfin-inc.com"
        ".openai.azure.com"
        ".baidu.com"
        ".aliyun-inc.com"
        ".aliyun-inc.test"
        ))

(setq my/user-agent
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36")

(use-package mb-url-http
  :demand
  :vc (:url "https://github.com/dochang/mb-url")
  :init
  (require 'auth-source)
  (let ((credential (auth-source-user-and-password "api.github.com")))
    (setq github-user (car credential)
          github-password (cadr credential))
    (setq github-auth (concat github-user ":" github-password))
    (setq mb-url-http-backend 'mb-url-http-curl
          mb-url-http-curl-program "/opt/homebrew/opt/curl/bin/curl"
          mb-url-http-curl-switches
          `("-k"
            "-x" ,my/socks-proxy
            "--keepalive-time" "60"
            "--keepalive"
            "--max-time" "300"
            ;;防止 POST 超过 1024 Bytes 时发送 `Expect: 100-continue` 导致 1s 延迟。
            "-H" "Expect: ''"
            ;;"-u" ,github-auth
            "--user-agent" ,my/user-agent
            ))))

;; 开启 socks5 代理。
(defun proxy-socks-enable ()
  (interactive)
  (require 'socks)
  (setq url-gateway-method 'socks
        socks-noproxy my/no-proxy
        socks-server `("Default server" ,my/socks-host ,my/socks-port 5))
  (let ((no-proxy (mapconcat 'identity my/no-proxy ",")))
    (setenv "no_proxy" no-proxy))
  (setenv "ALL_PROXY" my/socks-proxy)
  (setenv "ALL_PROXY" my/socks-proxy)
  (setenv "HTTP_PROXY" nil)
  (setenv "HTTPS_PROXY" nil)
  (advice-add 'url-http :around 'mb-url-http-around-advice))

;; 关闭 socks5 代理。
(defun proxy-socks-disable ()
  (interactive)
  (require 'socks)
  (setq url-gateway-method 'native socks-noproxy nil)
  (setenv "all_proxy" "")
  (setenv "ALL_PROXY" ""))

;; 默认启动时开启 socks5 代理。
(proxy-socks-enable)

(when (memq window-system '(mac ns x))
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (menu-bar-mode -1)
  (setq use-file-dialog nil)
  (setq use-dialog-box nil))

;; 高亮当前行。
(global-hl-line-mode t)
(setq global-hl-line-sticky-flag t)

;; 显示行号。
(global-display-line-numbers-mode t)

;; 设置光标样式。
(setq-default cursor-type 'bar)

;; 光标和字符宽度一致（如 TAB)。
(setq x-stretch-cursor t)

;; frame 边角样式：undecorated, round corner: undecorated-round
(add-to-list 'default-frame-alist '(undecorated . t))
(add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
(add-to-list 'default-frame-alist '(selected-frame) 'name nil)
(add-to-list 'default-frame-alist '(ns-appearance . dark))
;; 新建 frame window 的大小。
(add-to-list 'default-frame-alist '(height . 24))
(add-to-list 'default-frame-alist '(width . 80))

;; 不在新 frame 打开文件（如 Finder 的 "Open with Emacs") 。
(setq ns-pop-up-frames nil)

;; 复用当前 frame。
(setq display-buffer-reuse-frames t)
(setq frame-resize-pixelwise t)

;; 30: 左右分屏, nil: 上下分屏。
(setq split-width-threshold nil)

;; 刷新显示。
(global-set-key (kbd "<f5>") #'redraw-display)

(setq switch-to-buffer-obey-display-actions t)

;; 在 frame 底部显示的窗口列表。
(add-to-list
 'display-buffer-alist
 `((,(regexp-opt
      '("\\*compilation\\*"
        "\\*Apropos\\*"
        "\\*Help\\*"
        "\\*helpful"
        "\\*info\\*"
        "\\*Summary\\*"
        "\\*vt"
        "\\*lsp-bridge"
        "\\*Org"
        "\\*Google Translate\\*"
        " \\*eglot"
        "Shell Command Output"))
    ;; 复用同名 buffer 窗口。
    (display-buffer-reuse-window
     . (
	;; 在 frame 底部显示窗口。
	(side . bottom)
	;; 窗口高度比例。
	(window-height . 0.35)
	)))))

;; 启动后显示模式，加 t 参数让 togg-frame-XX 最后运行，这样才生效：
(add-hook 'window-setup-hook 'toggle-frame-maximized t) ;; toggle-frame-fullscreen

;; 切换窗口。
(global-set-key (kbd "s-o") #'other-window)

(setq window-combination-resize t)

;; 像素平滑滚动。
(pixel-scroll-precision-mode t)
(setq fast-but-imprecise-scrolling t)
(setq scroll-conservatively 10
      scroll-margin 2
      scroll-preserve-screen-position t
      mouse-wheel-scroll-amount '(2 ((shift) . hscroll))
      mouse-wheel-scroll-amount-horizontal 2)

(use-package dashboard
  :config
  (dashboard-setup-startup-hook)
  (setq-local global-hl-line-mode nil)
  (setq dashboard-banner-logo-title "Happy Hacking & Writing 🎯")
  (setq dashboard-projects-backend #'project-el)
  (setq dashboard-center-content t)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-navigator t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-path-max-length 30)
  ;; 显示 org-mode agenda。
  (add-to-list 'dashboard-items '(agenda) t)
  (setq dashboard-items '((recents . 20) (projects . 8) (agenda . 3))))

;; 使用 Symbols Nerd Fonts Mono 在 modeline 上显示 icons，需要单独下载和安装该字体。
(use-package nerd-icons)

(use-package doom-modeline
  :hook (after-init . doom-modeline-mode)
  :custom
  (doom-modeline-buffer-encoding nil)
  (doom-modeline-env-version nil)
  (doom-modeline-env-enable-rust nil)
  (doom-modeline-env-enable-go nil)
  (doom-modeline-buffer-file-name-style 'truncate-nil)
  (doom-modeline-vcs-max-length 30)
  (doom-modeline-github nil)
  (doom-modeline-time-icon nil)
  (doom-modeline-check-simple-format t)
  :config
  (display-battery-mode 0)
  (column-number-mode t)
  (display-time-mode t)
  (setq display-time-24hr-format t)
  (setq display-time-default-load-average nil)
  (setq display-time-load-average-threshold 20)
  (setq display-time-format "%H:%M ") ;; 默认："%m/%d[%w]%H:%M "
  (setq indicate-buffer-boundaries (quote left)))

;; 为 vterm-mode 定义简化的 modeline，避免 vterm buffer 内容过多时更新 modeline 影响性能。
(doom-modeline-def-modeline 'my-vterm-modeline
  '(buffer-info) ;; 左侧
  '(misc-info minor-modes input-method)) ;; 右侧
(add-to-list 'doom-modeline-mode-alist '(vterm-mode . my-vterm-modeline))

(use-package vscode-icon
  :commands (vscode-icon-for-file))

(use-package dired-sidebar
  :bind (("s-1" . dired-sidebar-toggle-sidebar))
  :commands (dired-sidebar-toggle-sidebar)
  :init
  (add-hook 'dired-sidebar-mode-hook
            (lambda ()
              (unless (file-remote-p default-directory)
                (auto-revert-mode))))
  :config
  (push 'toggle-window-split dired-sidebar-toggle-hidden-commands)
  (push 'rotate-windows dired-sidebar-toggle-hidden-commands)
  (setq dired-sidebar-subtree-line-prefix "-")
  (setq dired-sidebar-theme 'vscode) ;;'ascii
  (setq dired-sidebar-use-term-integration t)
  (setq dired-sidebar-use-one-instance t)
  (setq dired-sidebar-use-custom-font t)
  (setq dired-sidebar-icon-scale 0.1)
  (setq dired-sidebar-follow-file-idle-delay 0.5))

(use-package fontaine
  :config
  (setq fontaine-latest-state-file (locate-user-emacs-file "fontaine-latest-state.eld"))
  (setq fontaine-presets
	'((regular) ;; 使用缺省配置。
	  (t
	   :default-family "Iosevka Comfy"
	   :default-weight regular
	   :default-height 180 ;; 默认字号, 需要是偶数才能实现中英文等宽等高。
	   :fixed-pitch-family "Iosevka Comfy"
	   :fixed-pitch-weight nil
	   :fixed-pitch-height 1.0
	   :fixed-pitch-serif-family "Iosevka Comfy"
	   :fixed-pitch-serif-weight nil
	   :fixed-pitch-serif-height 1.0
	   :variable-pitch-family "Iosevka Comfy Duo"
	   :variable-pitch-weight nil
	   :variable-pitch-height 1.0
	   :line-spacing nil)))
  (fontaine-mode 1)
  (add-hook 'enable-theme-functions #'fontaine-apply-current-preset)
  (fontaine-set-preset (or (fontaine-restore-latest-preset) 'regular))
  (add-hook 'kill-emacs-hook #'fontaine-store-latest-preset))

;; 设置 emoji/symbol 和中文字体。
(defun my/set-font ()
  (when window-system
    (setq use-default-font-for-symbols nil)
    (set-fontset-font t 'emoji (font-spec :family "Apple Color Emoji")) ;; Noto Color Emoji
    (set-fontset-font t 'symbol (font-spec :family "Symbola")) ;; Apple Symbols, Symbola
    (let ((font (frame-parameter nil 'font))
	  (font-spec (font-spec :family "LXGW WenKai Screen")))
      (dolist (charset '(kana han hangul cjk-misc bopomofo))
	(set-fontset-font font charset font-spec)))))

;; Emacs 启动后或 fontaine preset 切换时设置字体。
(add-hook 'after-init-hook 'my/set-font)
(add-hook 'fontaine-set-preset-hook 'my/set-font)

;; 设置字体缩放比例，设置为 1.172 可以确保 2 倍放大后对应的是 22 号偶数字体，这样表格
;; 可以对齐。16 * 1.172 * 1.172 = 21.97（Emacs 取整为 22）。
(setq text-scale-mode-step 1.172)

;; org-table 只使用中英文严格等宽的 LXGW WenKai Mono Screen 字体, 避免中英文不对齐。
(custom-theme-set-faces 'user '(org-table ((t (:family "LXGW WenKai Mono Screen")))))

(use-package ef-themes
  :demand
  :config
  (mapc #'disable-theme custom-enabled-themes)
  (setq ef-themes-variable-pitch-ui t)
  (setq ef-themes-mixed-fonts t)
  (setq ef-themes-headings
        '(
          ;; level 0 是文档 title，1-8 是文档 header。
          (0 . (variable-pitch light 1.9))
          (1 . (variable-pitch light 1.8))
          (2 . (variable-pitch regular 1.7))
          (3 . (variable-pitch regular 1.6))
          (4 . (variable-pitch regular 1.5))
          (5 . (variable-pitch 1.4))
          (6 . (variable-pitch 1.3))
          (7 . (variable-pitch 1.2))
          (8 . (variable-pitch 1.1))
          (t . (variable-pitch 1.1))))
  (setq ef-themes-region '(intense no-extend neutral)))

(defun my/load-theme (appearance)
  (interactive)
  (pcase appearance
    ('light (load-theme 'ef-light t))
    ('dark (load-theme 'ef-elea-dark t))))
(add-hook 'ns-system-appearance-change-functions 'my/load-theme)
(add-hook 'after-init-hook (lambda () (my/load-theme ns-system-appearance)))

(use-package tab-bar
  :custom
  (tab-bar-close-button-show nil)
  (tab-bar-new-button-show nil)
  (tab-bar-history-limit 20)
  (tab-bar-new-tab-choice "*dashboard*")
  (tab-bar-show 1)
  ;; 使用 super + N 切换 tab。
  (tab-bar-select-tab-modifiers "super")
  :config
  ;; 去掉最左侧的 < 和 > 。
  (setq tab-bar-format '(tab-bar-format-tabs tab-bar-separator))
  ;; 开启 tar-bar history mode 后才支持 history-back/forward 命令。
  (tab-bar-history-mode t)
  (global-set-key (kbd "s-f") 'tab-bar-history-forward)
  (global-set-key (kbd "s-b") 'tab-bar-history-back)
  (global-set-key (kbd "s-t") 'tab-bar-new-tab)
  (keymap-global-set "s-n" 'tab-bar-switch-to-next-tab)
  (keymap-global-set "s-p" 'tab-bar-switch-to-prev-tab)
  (keymap-global-set "s-w" 'tab-bar-close-tab)

  ;; 为 tab 添加序号，用于快速切换。
  (defvar ct/circle-numbers-alist
    '((0 . "⓪")
      (1 . "①")
      (2 . "②")
      (3 . "③")
      (4 . "④")
      (5 . "⑤")
      (6 . "⑥")
      (7 . "⑦")
      (8 . "⑧")
      (9 . "⑨"))
    "Alist of integers to strings of circled unicode numbers.")
  (setq tab-bar-tab-hints t)
  (defun ct/tab-bar-tab-name-format-default (tab i)
    (let ((current-p (eq (car tab) 'current-tab))
          (tab-num (if (and tab-bar-tab-hints (< i 10))
                       (alist-get i ct/circle-numbers-alist) "")))
      (propertize
       (concat tab-num
               " "
               (alist-get 'name tab)
               (or (and tab-bar-close-button-show
                        (not (eq tab-bar-close-button-show
                                 (if current-p 'non-selected 'selected)))
                        tab-bar-close-button)
                   "")
               " ")
       'face (funcall tab-bar-tab-face-function tab))))
  (setq tab-bar-tab-name-format-function #'ct/tab-bar-tab-name-format-default)

  (global-set-key (kbd "s-1") 'tab-bar-select-tab)
  (global-set-key (kbd "s-2") 'tab-bar-select-tab)
  (global-set-key (kbd "s-3") 'tab-bar-select-tab)
  (global-set-key (kbd "s-4") 'tab-bar-select-tab)
  (global-set-key (kbd "s-5") 'tab-bar-select-tab)
  (global-set-key (kbd "s-6") 'tab-bar-select-tab)
  (global-set-key (kbd "s-7") 'tab-bar-select-tab)
  (global-set-key (kbd "s-8") 'tab-bar-select-tab)
  (global-set-key (kbd "s-9") 'tab-bar-select-tab))

(use-package rime
  :custom
  (rime-user-data-dir "~/Library/Rime/")
  (rime-librime-root "~/.emacs.d/librime/dist")
  (rime-emacs-module-header-root "/opt/homebrew/opt/emacs-plus@30/include")
  :hook
  (emacs-startup . (lambda () (setq default-input-method "rime")))
  :bind
  (
   :map rime-active-mode-map
   ;; 在已经激活 Rime 候选菜单时，强制切换到英文直到按回车。
   ("M-j" . 'rime-inline-ascii)
   :map rime-mode-map
   ;; 强制切换到中文模式.
   ("M-j" . 'rime-force-enable)
   ;; 下面这些快捷键需要发送给 rime 来处理, 需要与 default.custom.yaml 文件中的
   ;; key_binder/bindings配置相匹配。
   ("C-." . 'rime-send-keybinding)      ;; 中英文切换
   ("C-+" . 'rime-send-keybinding)      ;; 输入法菜单
   ("C-," . 'rime-send-keybinding)      ;; 中英文标点切换
   ;;("C-," . 'rime-send-keybinding)    ;; 全半角切换
   )
  :config
  ;; 在 modline 高亮输入法图标, 可用来快速分辨分中英文输入状态。
  (setq mode-line-mule-info '((:eval (rime-lighter))))
  ;; 将如下快捷键发送给 rime，同时需要在 rime 的 key_binder/bindings 的部分配置才会生
  ;; 效。
  (add-to-list 'rime-translate-keybindings "C-h") ;; 删除拼音字符
  (add-to-list 'rime-translate-keybindings "C-d")
  (add-to-list 'rime-translate-keybindings "C-k") ;; 删除误上屏的词语
  (add-to-list 'rime-translate-keybindings "C-a") ;; 跳转到第一个拼音字符
  (add-to-list 'rime-translate-keybindings "C-e") ;; 跳转到最后一个拼音字符support
  ;; shift-l, shift-r, control-l, control-r, 只有当使用系统 RIME 输入法时才有效。
  (setq rime-inline-ascii-trigger 'shift-r)
  ;; 临时英文模式, 该列表中任何一个断言返回 t 时自动切换到英文。如果
  ;; rime-inline-predicates 不为空，则当其中任意一个断言也返回 t 时才会自动切换到英文
  ;; （inline 等效于 ascii-mode）。自定义 avy 断言函数。
  (defun rime-predicate-avy-p () (bound-and-true-p avy-command))
  (setq rime-disable-predicates
        '(rime-predicate-ace-window-p
          rime-predicate-hydra-p
          ;;rime-predicate-current-uppercase-letter-p
          ;; 在上一个字符是英文时才自动切换到英文，适合字符串中中英文混合的情况。
          ;;rime-predicate-in-code-string-after-ascii-p
          ;; 代码块内不能输入中文, 但注释和字符串不受影响。
          ;;rime-predicate-prog-in-code-p
          ;;rime-predicate-avy-p
          ))
  (setq rime-show-candidate 'posframe)
  (setq default-input-method "rime")

  (setq rime-posframe-properties
        (list :background-color "#333333"
              :foreground-color "#dcdccc"
              :internal-border-width 2))

  ;; 部分 mode 关闭 RIME 输入法。
  (defadvice switch-to-buffer (after activate-input-method activate)
    (if (or (string-match "vterm-mode" (symbol-name major-mode))
            (string-match "dired-mode" (symbol-name major-mode))
            (string-match "image-mode" (symbol-name major-mode))
            (string-match "compilation-mode" (symbol-name major-mode))
            (string-match "isearch-mode" (symbol-name major-mode))
            (string-match "minibuffer-mode" (symbol-name major-mode)))
        (activate-input-method nil)
      (activate-input-method "rime"))))

(use-package vertico
  :config
  (setq vertico-count 15)
  (vertico-mode 1)
  (define-key vertico-map (kbd "<backspace>") #'vertico-directory-delete-char)
  (define-key vertico-map (kbd "RET") #'vertico-directory-enter))

(use-package emacs
  :init
  ;; minibuffer 不显示光标。
  (setq minibuffer-prompt-properties '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)
  ;; M-x 只显示当前 mode 支持的命令。
  (setq read-extended-command-predicate #'command-completion-default-include-p)
  ;; 开启 minibuffer 递归编辑。
  (setq enable-recursive-minibuffers t))

(use-package corfu
  :init
  (global-corfu-mode 1)
  (corfu-popupinfo-mode 1) ;; 显示候选者文档。
  :bind
  ;; 滚动显示 corfu-popupinfo 内容的快捷键。
  (:map corfu-popupinfo-map
        ("C-M-j" . corfu-popupinfo-scroll-up)
        ("C-M-k" . corfu-popupinfo-scroll-down))
  :custom
  (corfu-cycle t)                ;; 自动轮转。
  (corfu-auto t)                 ;; 自动补全(不需要按 TAB)。
  (corfu-auto-prefix 2)          ;; 触发自动补全的前缀长度。
  (corfu-auto-delay 0.1)         ;; 触发自动补全的延迟, 当满足前缀长度或延迟时, 都会自动补全。
  (corfu-separator ?\s)          ;; 使用 Orderless 过滤分隔符。
  (corfu-preselect 'prompt)      ;; Preselect the prompt
  (corfu-scroll-margin 5)
  (corfu-on-exact-match nil)     ;; 默认不选中候选者(即使只有一个)。
  (corfu-popupinfo-delay '(0.1 . 0.2)) ;; 候选者帮助文档显示延迟。
  (corfu-popupinfo-max-width 80)
  (corfu-popupinfo-max-height 50)
  (corfu-popupinfo-direction '(force-right)) ;; 强制在右侧显示文档。
  :config
  (defun corfu-enable-always-in-minibuffer ()
    (setq-local corfu-auto nil)
    (corfu-mode 1))
  (add-hook 'minibuffer-setup-hook #'corfu-enable-always-in-minibuffer 1)

  ;; corfu 支持 eshell 的 pcomplete 自动补全。
  (add-hook 'eshell-mode-hook
            (lambda ()
              (setq-local corfu-auto nil)
              (corfu-mode))))

;; 记录 minibuffer 和 corfu 补全历史，后续显示候选者时按照频率排序。
(use-package savehist
  :hook (after-init . savehist-mode)
  :config
  (setq history-length 100)
  (setq savehist-save-minibuffer-history t)
  (setq savehist-autosave-interval 300)
  (add-to-list 'savehist-additional-variables #'corfu-history)
  (add-to-list 'savehist-additional-variables 'mark-ring)
  (add-to-list 'savehist-additional-variables 'global-mark-ring)
  (add-to-list 'savehist-additional-variables 'extended-command-history))

(use-package emacs
  :init
  ;; 总是在弹出菜单中显示候选者。
  (setq completion-cycle-threshold nil)
  ;; 使用 TAB 来 indentation + completion(completion-at-point 默认是 M-TAB) 。
  (setq tab-always-indent 'complete))

(use-package orderless
  :demand t
  :config
  ;; https://github.com/minad/consult/wiki#minads-orderless-configuration
  (defun +orderless--consult-suffix ()
    "Regexp which matches the end of string with Consult tofu support."
    (if (and (boundp 'consult--tofu-char) (boundp 'consult--tofu-range))
        (format "[%c-%c]*$"
                consult--tofu-char
                (+ consult--tofu-char consult--tofu-range -1))
      "$"))

  ;; Recognizes the following patterns:
  ;; * .ext (file extension)
  ;; * regexp$ (regexp matching at end)
  (defun +orderless-consult-dispatch (word _index _total)
    (cond
     ;; Ensure that $ works with Consult commands, which add disambiguation suffixes
     ((string-suffix-p "$" word)
      `(orderless-regexp . ,(concat (substring word 0 -1) (+orderless--consult-suffix))))
     ;; File extensions
     ((and (or minibuffer-completing-file-name
               (derived-mode-p 'eshell-mode))
           (string-match-p "\\`\\.." word))
      `(orderless-regexp . ,(concat "\\." (substring word 1) (+orderless--consult-suffix))))))

  ;; 在 orderless-affix-dispatch 的基础上添加上面支持文件名扩展和正则表达式的 dispatchers。
  (setq orderless-style-dispatchers
        (list #'+orderless-consult-dispatch
              #'orderless-affix-dispatch))

  ;; 自定义名为 +orderless-with-initialism 的 orderless 风格。
  (orderless-define-completion-style +orderless-with-initialism
    (orderless-matching-styles '(orderless-initialism orderless-literal orderless-regexp)))

  ;; 使用 orderless 和 Emacs 原生的 basic 补全风格，但 orderless 的优先级更高。
  (setq completion-styles '(orderless basic))
  (setq completion-category-defaults nil)

  ;; 设置 Emacs minibuffer 各 category 使用的补全风格。
  (setq completion-category-overrides
        '(
          ;; buffer name 补全
          ;;(buffer (styles +orderless-with-initialism))

          ;; 文件名和路径补全, partial-completion 提供了 wildcard 支持。
          (file (styles partial-completion))
          (command (styles +orderless-with-initialism))
          (variable (styles +orderless-with-initialism))
          (symbol (styles +orderless-with-initialism))

          ;; eglot will change the completion-category-defaults to flex, BAD!
          ;; https://github.com/minad/corfu/issues/136#issuecomment-eglot
          ;; 使用 M-SPC 来分隔光标处的多个筛选条件。
          (eglot (styles . (orderless basic)))
          (eglot-capf (styles . (orderless basic)))
          ))

  ;; 使用 SPACE 来分割过滤字符串。
  (setq orderless-component-separator #'orderless-escapable-split-on-space))

(use-package consult
  :hook
  (completion-list-mode . consult-preview-at-point-mode)
  :init
  ;; 如果搜索字符少于 3，可以添加后缀 # 开始搜索，如 #gr#。
  (setq consult-async-min-input 3)
  ;; 从头开始搜索（而非前位置）。
  (setq consult-line-start-from-top t)
  ;; 寄存器预览。
  (setq register-preview-function #'consult-register-format)
  (advice-add #'register-preview :override #'consult-register-window)
  :config
  ;; 不搜索 go vendor 目录。
  (setq consult-ripgrep-args (concat consult-ripgrep-args " -g !vendor/"))
  ;; 按 C-l 才激活预览，否则 Buffer 列表中有大文件或远程文件时会卡住。
  (setq consult-preview-key "C-l")
  ;; 不对 consult-line 结果进行排序（按行号排序）。
  (consult-customize consult-line :prompt "Search: " :sort nil)
  ;; Buffer 列表中不显示的 Buffer 名称。
  (mapcar
   (lambda (pattern) (add-to-list 'consult-buffer-filter pattern))
   '("\\*scratch\\*"
     "\\*Warnings\\*"
     "\\*helpful.*"
     "\\*Help\\*"
     "\\*Org Src.*"
     "Pfuture-Callback.*"
     "\\*epc con"
     "\\*dashboard"
     "\\*Ibuffer"
     "\\*sort-tab"
     "\\*Google Translate\\*"
     "\\*straight-process\\*"
     "\\*Native-compile-Log\\*"
     "\\*EGLOT"
     "[0-9]+.gpg")))

;; 执行 consult-line 命令时自动展开 org 内容。
;; https://github.com/minad/consult/issues/563#issuecomment-1186612641
(defun my/org-show-entry (fn &rest args)
  (interactive)
  (when-let ((pos (apply fn args)))
    (when (derived-mode-p 'org-mode)
      (org-fold-show-entry))))
(advice-add 'consult-line :around #'my/org-show-entry)

;; 显示 mode 相关的命令。
(global-set-key (kbd "C-c M-x") #'consult-mode-command)

;; 搜索 Emacs 各 package/mode 的 info 和 man 文档。
(global-set-key (kbd "C-c i") #'consult-info)
(global-set-key (kbd "C-c m") #'consult-man)

;; 使用 savehist 持久化保存的 minibuffer 历史。
(global-set-key (kbd "C-M-;") #'consult-complex-command)

;; consult-buffer 显示的 File 列表来源于变量 recentf-list。
(global-set-key (kbd "C-x b") #'consult-buffer)
(global-set-key (kbd "C-x 4 b") #'consult-buffer-other-window)
(global-set-key (kbd "C-x 5 b") #'consult-buffer-other-frame)
(global-set-key (kbd "C-x r b") #'consult-bookmark)
(global-set-key (kbd "C-x p b") #'consult-project-buffer)

(global-set-key (kbd "M-y") #'consult-yank-pop)
(global-set-key (kbd "M-Y") #'consult-yank-from-kill-ring)

(global-set-key (kbd "M-g g") #'consult-goto-line)
(global-set-key (kbd "M-g o") #'consult-outline)

;; 寄存器，保存 point、file、window、frame 的位置。
(global-set-key (kbd "C-'") #'consult-register-store)
(global-set-key (kbd "C-M-'") #'consult-register)

;; 显示编译错误列表。
(global-set-key (kbd "M-g e") #'consult-compile-error)
;; 显示 flymake 诊断错误列表。
(global-set-key (kbd "M-g f") #'consult-flymake)

;; consult-buffer 默认已包含 recent file。
;;(global-set-key (kbd "M-g r") #'consult-recent-file)

(global-set-key (kbd "M-g m") #'consult-mark)
(global-set-key (kbd "M-g k") #'consult-global-mark)

;; 预览当前 buffer 的 imenu。
(global-set-key (kbd "M-g i") #'consult-imenu)
;; 预览当前 project 打开的所有 buffer 的 imenu。
(global-set-key (kbd "M-g I") #'consult-imenu-multi)

;; 搜索文件内容。
(global-set-key (kbd "M-s g") #'consult-grep)
(global-set-key (kbd "M-s G") #'consult-git-grep)
(global-set-key (kbd "M-s r") #'consult-ripgrep)

;; 搜索文件名（正则匹配）。
(global-set-key (kbd "M-s d") #'consult-find)
(global-set-key (kbd "M-s D") #'consult-locate)

;; 搜索当前 buffer
(global-set-key (kbd "M-s l") #'consult-line)
(global-set-key (kbd "M-s M-l") #'consult-line)
;; 搜索多个 buffer，默认为 project 的多个 buffers。
;; 如果使用前缀参数，则搜索所有 buffers。
(global-set-key (kbd "M-s L") #'consult-line-multi)

;; Isearch 集成。
(global-set-key (kbd "M-s e") #'consult-isearch-history)
;;:map isearch-mode-map
(define-key isearch-mode-map (kbd "M-e") #'consult-isearch-history)
(define-key isearch-mode-map (kbd "M-s e") #'consult-isearch-history)
(define-key isearch-mode-map (kbd "M-s l") #'consult-line)
(define-key isearch-mode-map (kbd "M-s L") #'consult-line-multi)

;; Minibuffer 历史。
;;:map minibuffer-local-map)
(define-key minibuffer-local-map (kbd "M-s") #'consult-history)
(define-key minibuffer-local-map (kbd "M-r") #'consult-history)

;; 使用 consult 来预览 xref 的引用定义和跳转。
(setq xref-show-xrefs-function #'consult-xref)
(setq xref-show-definitions-function #'consult-xref)

;; 限制 xref history 仅局限于当前窗口（默认全局）。
(setq xref-history-storage 'xref-window-local-history)

;; 在其它窗口查看定义。
(global-set-key (kbd "C-M-.") 'xref-find-definitions-other-window)

(use-package embark
  :init
  ;; 使用 C-h 显示 key preifx 绑定。
  (setq prefix-help-command #'embark-prefix-help-command)
  :config
  (setq embark-prompter 'embark-keymap-prompter)
  (global-set-key (kbd "C-;") #'embark-act) ;; embark-dwim
  ;; 根据当前 buffer 的 mode，显示可以使用的快捷键。
  (define-key global-map [remap describe-bindings] #'embark-bindings))

;; embark-consult 支持 embark 和 consult 集成，使用 wgrep 编辑 consult grep/line 的 export 的结果。
(use-package embark-consult
  :after (embark consult)
  :hook  (embark-collect-mode . consult-preview-at-point-mode))

;; 编辑 grep buffers, 可以和 consult-grep 和 embark-export 联合使用。
(use-package wgrep
  :config
  ;; 执行 wgre-finished-edit 时保存所有修改的 buffer。
  (setq wgrep-auto-save-buffer t)
  (setq wgrep-change-readonly-file t))

(use-package marginalia
  :init
  ;; 显示绝对时间。
  (setq marginalia-max-relative-age 0)
  (marginalia-mode))

(use-package org
  :config
  (setq
   org-ellipsis "..." ;; " ⭍"

   ;; 使用 UTF-8 显示 LaTeX 或 \xxx 特殊字符， M-x org-entities-help 查看所有特殊字符。
   org-pretty-entities t
   org-highlight-latex-and-related '(latex)

   ;; 只显示而不处理和解释 latex 标记，例如 \xxx 或 \being{xxx}, 避免 export pdf 时出错。
   org-export-with-latex 'verbatim
   org-export-with-broken-links 'mark
   ;; export 时不处理 super/sub scripting, 等效于 #+OPTIONS: ^:nil 。
   org-export-with-sub-superscripts nil
   org-export-default-language "zh-CN"
   org-export-coding-system 'utf-8

   ;; 使用 R_{s} 形式的下标（默认是 R_s, 容易与正常内容混淆) 。
   org-use-sub-superscripts nil

   ;; 文件链接使用相对路径, 解决 hugo 等 image 引用的问题。
   org-link-file-path-type 'relative
   org-html-validation-link nil
   ;; 关闭鼠标点击链接。
   org-mouse-1-follows-link nil

   org-hide-emphasis-markers t
   org-hide-block-startup t
   org-hidden-keywords '(title)
   org-hide-leading-stars t

   org-cycle-separator-lines 2
   org-cycle-level-faces t
   org-n-level-faces 4
   org-indent-indentation-per-level 2

   ;; 内容缩进与对应 headerline 一致。
   org-adapt-indentation t
   org-list-indent-offset 2

   ;; 代码块缩进。
   org-src-preserve-indentation t
   org-edit-src-content-indentation 0

   ;; TODO 状态更新记录到 LOGBOOK Drawer 中。
   org-log-into-drawer t
   ;; TODO 状态更新时记录 note.
   org-log-done 'note ;; note, time

   ;; 不显示图片（手动点击显示更容易控制大小）。
   org-startup-with-inline-images nil
   org-startup-folded 'content
   org-cycle-inline-images-display nil

   ;; 如果对 headline 编号则 latext 输出时会导致 toc 缺失，故关闭。
   org-startup-numerated nil
   org-startup-indented t

   ;; 先从 #+ATTR.* 获取宽度，如果没有设置则默认为 300 。
   org-image-actual-width '(300)

   ;; org-timer 到期时发送声音提示。
   org-clock-sound t
   ;; 关闭容易误按的 archive 命令。
   org-archive-default-command nil

   ;; 不自动对齐 tag。
   org-tags-column 0
   org-auto-align-tags nil

   ;; 显示不可见的编辑。
   org-catch-invisible-edits 'show-and-error
   org-fold-catch-invisible-edits t

   ;; 支持 ID property 作为 internal link target(默认是 CUSTOM_ID property)
   org-id-link-to-org-use-id t
   org-M-RET-may-split-line nil

   ;; 关闭频繁弹出的 org-element-cache 警告 buffer 。
   org-element-use-cache nil

   org-todo-keywords
   '((sequence "TODO(t!)" "DOING(d@)" "|" "DONE(D)")
     (sequence "WAITING(w@/!)" "NEXT(n!/!)" "SOMEDAY(S)" "|" "CANCELLED(c@/!)"))

   org-special-ctrl-a/e t
   org-insert-heading-respect-content t)

  ;;(add-hook 'org-mode-hook 'turn-on-auto-fill)
  (add-hook 'org-mode-hook (lambda () (display-line-numbers-mode 0))))

(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)
(global-set-key (kbd "C-c b") #'org-switchb)

;; 关闭 org-mode 的 C-c C-j 快捷键, 与 journal 冲突.
(define-key org-mode-map (kbd "C-c C-j") nil)
;; 关闭 org-mode 的 C-' 对应的 org-cycle-agenda-files 命令, 与 consult-register-store 冲突。
(define-key org-mode-map (kbd "C-'") nil)

;; 光标位于 src block 中执行 C-c C-f 时自动格式化 block 中代码。
(defun my/format-src-block ()
  "Formats the code in the current src block."
  (interactive)
  (org-edit-special)
  (indent-region (point-min) (point-max))
  (org-edit-src-exit))

(defun my/org-mode-keys ()
  "Modify keymaps used in org-mode."
  (let ((map (if (org-in-src-block-p)
                 org-src-mode-map
               org-mode-map)))
    (define-key map (kbd "C-c C-f") 'my/format-src-block)))
(add-hook 'org-mode-hook 'my/org-mode-keys)

;; 建立 org 相关目录。
(dolist (dir '("~/docs/org" "~/docs/org/journal"))
  (unless (file-directory-p dir)
    (make-directory dir)))

;; 关闭 C-c C-c 触发执行代码.
(setq org-babel-no-eval-on-ctrl-c-ctrl-c t)

;; 确认执行代码的操作。
(setq org-confirm-babel-evaluate t)

;; 使用语言的 mode 来格式化代码.
(setq org-src-fontify-natively t)

;; 使用各语言的 Major Mode 来编辑 src block。
(setq org-src-tab-acts-natively t)

;; yaml 从外部的 yaml-mode 切换到内置的 yaml-ts-mode，告诉 babel 使用该内置 mode，否则编辑 yaml src
;; block 时提示找不到 yaml-mode。
(add-to-list 'org-src-lang-modes '("yaml" . yaml-ts))
(add-to-list 'org-src-lang-modes '("cue" . cue))

(require 'org)
;; org bable 完整支持的语言列表（ob- 开头的文件）：
;; https://git.savannah.gnu.org/cgit/emacs/org-mode.git/tree/lisp 对于官方不支持的语言，可以通过
;; use-pacakge 来安装。
(use-package ob-go)
(use-package ob-rust)
(org-babel-do-load-languages
 'org-babel-load-languages
 '((shell . t)
   (js . t)
   (makefile . t)
   (go . t)
   (emacs-lisp . t)
   (rust . t)
   (python . t)
   (C . t) ;; 支持 C/C++/D
   (java . t)
   (awk . t)
   (css . t)))

(use-package org-contrib)

(use-package olivetti
  :config
  ;; 文本区域宽度，超过后自动折行。
  (setq-default olivetti-body-width 130)
  (add-hook 'org-mode-hook 'olivetti-mode))

;; fill-column 值要小于 olivetti-body-width 才能正常折行。
(setq-default fill-column 100)

;; 由于 auto-fill 可能会打乱代码的字符串和注释，故为 prog-mode/text-mode 等全局关闭 auto-fill。
;;(add-hook 'text-mode-hook 'turn-on-auto-fill)

(use-package org-modern
  :after (org)
  :config
  ;; 各种符号字体：https://github.com/rime/rime-prelude/blob/master/symbols.yaml
  ;;(setq org-modern-star '("◉" "○" "✸" "✿" "✤" "✜" "◆" "▶"))
  (setq org-modern-star '("⚀" "⚁" "⚂" "⚃" "⚄" "⚅"))
  (setq org-modern-block-fringe nil)
  (setq org-modern-block-name
        '((t . t)
          ("src" "»" "«")
          ("SRC" "»" "«")
          ("example" "»–" "–«")
          ("quote" "❝" "❞")))
  ;; 美化表格。
  (setq org-modern-table t)
  (setq org-modern-list
        '(
          (?* . "✤")
          (?+ . "▶")
          (?- . "◆")))
  (with-eval-after-load 'org (global-org-modern-mode)))

;; 显示转义字符。
(use-package org-appear
  :custom
  (org-appear-autolinks t)
  :hook (org-mode . org-appear-mode))

(use-package org-download
  :config
  ;; 保存路径包含 /static/ 时, ox-hugo 在导出时保留后面的目录层次。
  (setq-default org-download-image-dir "./static/images/")
  (setq org-download-method 'directory
        org-download-display-inline-images 'posframe
        org-download-screenshot-method "pngpaste %s"
        org-download-image-attr-list '("#+ATTR_HTML: :width 400 :align center"))
  (add-hook 'dired-mode-hook 'org-download-enable)
  (org-download-enable)
  (global-set-key (kbd "<f6>") #'org-download-screenshot)
  ;; 不添加 #+DOWNLOADED: 注释。
  (setq org-download-annotate-function (lambda (link) (previous-line 1) "")))

;; 将安装的 tex 二进制目录添加到 PATH 环境变量和 exec-path 变量中， Emacs 执行
;; xelatex 命令时使用。
(setq my-tex-path "/Library/TeX/texbin")
(setenv "PATH" (concat my-tex-path ":" (getenv "PATH")))
(setq exec-path (cons my-tex-path  exec-path))

;; engrave-faces 比 minted 渲染速度更快。
(use-package engrave-faces
  :after ox-latex
  :config
  (require 'engrave-faces-latex)
  (setq org-latex-src-block-backend 'engraved)
  ;; 代码块左侧添加行号。
  (add-to-list 'org-latex-engraved-options '("numbers" . "left"))
  ;; 代码块主题。
  (setq org-latex-engraved-theme 'ef-light))

(defun my/export-pdf (backend)
  (progn
    ;;(setq org-export-with-toc nil)
    (setq org-export-headline-levels 2))
  )
(add-hook 'org-export-before-processing-functions #'my/export-pdf)

;; ox- 为 org-mode 的导出后端包的惯例前缀。

;;(use-package ox-reveal) ;; reveal.js
(use-package ox-gfm :defer t) ;; github flavor markdown

(require 'ox-latex)
(with-eval-after-load 'ox-latex
  ;; latex image 的默认宽度, 可以通过 #+ATTR_LATEX :width xx 配置。
  (setq org-latex-image-default-width "0.7\\linewidth")
  ;; 使用 booktabs style 来显示表格，例如支持隔行颜色, 这样 #+ATTR_LATEX: 中不需要添
  ;; 加 :booktabs t。
  (setq org-latex-tables-booktabs t)
  ;; 不保存 LaTeX 日志文件（调试时设置为 nil）。
  (setq org-latex-remove-logfiles t)
  ;; 使用支持中文的 xelatex。
  (setq org-latex-pdf-process '("latexmk -xelatex -quiet -shell-escape -f %f"))
  (add-to-list 'org-latex-classes
	       '("ctexart"
                 "\\documentclass[lang=cn,11pt,a4paper,table]{ctexart}
                    [NO-DEFAULT-PACKAGES]
                    [PACKAGES]
                    [EXTRA]"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))))

;; org export html 格式时需要 htmlize.el 包来格式化代码。
(use-package htmlize)

(use-package dslide
  :vc(:url "https://github.com/positron-solutions/dslide.git")
  :hook
  ((dslide-start
    .
    (lambda ()
      (org-fold-hide-block-all)
      (setq-default x-stretch-cursor -1)
      (redraw-display)
      (blink-cursor-mode -1)
      (setq cursor-type 'bar)
      ;;(org-display-inline-images)
      ;;(hl-line-mode -1)
      (text-scale-increase 2)
      (read-only-mode 1)))
   (dslide-stop
    .
    (lambda ()
      (blink-cursor-mode +1)
      (setq-default x-stretch-cursor t)
      (setq cursor-type t)
      (text-scale-increase 0)
      ;;(hl-line-mode 1)
      (read-only-mode -1))))
  :config
  (setq dslide-margin-content 0.5)
  (setq dslide-animation-duration 0.5)
  (setq dslide-margin-title-above 0.3)
  (setq dslide-margin-title-below 0.3)
  (setq dslide-header-email nil)
  (setq dslide-header-date nil)
  (define-key org-mode-map (kbd "<f8>") #'dslide-deck-start)
  (define-key dslide-mode-map (kbd "<f9>") #'dslide-deck-stop))

(use-package org-journal
  :commands org-journal-new-entry
  :bind (("C-c j" . org-journal-new-entry))
  :init
  (setq org-journal-prefix-key "C-c j")
  (defun org-journal-save-entry-and-exit()
    (interactive)
    (save-buffer)
    (kill-buffer-and-window))
  :config
  (define-key org-journal-mode-map (kbd "C-c C-e") #'org-journal-save-entry-and-exit)
  (define-key org-journal-mode-map (kbd "C-c C-j") #'org-journal-new-entry)
  (global-set-key (kbd "C-c C-j") #'org-journal-new-entry)

  ;; 设置日志文件头。
  (defun org-journal-file-header-func (time)
    "Custom function to create journal header."
    (concat
     (pcase org-journal-file-type
       (`daily "#+TITLE: Daily Journal\n#+STARTUP: showeverything")
       (`weekly "#+TITLE: Weekly Journal\n#+STARTUP: folded")
       (`monthly "#+TITLE: Monthly Journal\n#+STARTUP: folded")
       (`yearly "#+TITLE: Yearly Journal\n#+STARTUP: folded"))))
  (setq org-journal-file-header 'org-journal-file-header-func)
  (setq org-journal-file-type 'daily) ;; 按天记录。

  (setq org-journal-dir "~/docs/org/journal")
  (setq org-journal-find-file 'find-file)

  ;; 加密日记文件。
  (setq org-journal-enable-encryption t)
  (setq org-journal-encrypt-journal t)
  (defun my-old-carryover (old_carryover)
    (save-excursion
      (let ((matcher (cdr (org-make-tags-matcher org-journal-carryover-items))))
	(dolist (entry (reverse old_carryover))
          (save-restriction
            (narrow-to-region (car entry) (cadr entry))
            (goto-char (point-min))
            (org-scan-tags '(lambda ()
                              (org-set-tags ":carried:"))
                           matcher org--matcher-tags-todo-only))))))
  (setq org-journal-handle-old-carryover 'my-old-carryover))

(use-package ox-hugo
  :demand
  :config
  (setq org-hugo-base-dir (expand-file-name "~/blog/blog.opsnull.com/"))
  (setq org-hugo-section "posts")
  (setq org-hugo-front-matter-format "yaml")
  (setq org-hugo-export-with-section-numbers t)
  (setq org-export-backends '(go md gfm html latex man hugo))
  (setq org-hugo-auto-set-lastmod t))

(use-package indent-bars
  :vc (:url "https://github.com/jdtsmith/indent-bars")
  :config
  (require 'indent-bars-ts)
  :custom
  (indent-bars-treesit-support t)
  (indent-bars-treesit-ignore-blank-lines-types '("module"))
  (indent-bars-treesit-scope
   '((python
      function_definition
      class_definition
      for_statement
      if_statement
      with_statement
      while_statement)))
  :hook
  ((python-base-mode
    yaml-ts-mode
    json-ts-mode
    js-ts-mode) . indent-bars-mode))

;; 默认不使用 tab 缩进。
;;(setq indent-tabs-mode t)
(setq c-ts-mode-indent-offset 8)
(setq c-ts-common-indent-offset 8)
(setq c-basic-offset 8)
;; kernel 风格：table 和 offset 都是 tab 缩进，而且都是 8 字符。
;; https://www.kernel.org/doc/html/latest/process/coding-style.html
(setq c-default-style "linux")
(setq tab-width 8)

;; 关闭 electric-indent-mode，同时重新定义 C-j 和 C-m 快捷键，使用 major-mode 的缩进规则。
;;(electric-indent-mode 0)

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package paren
  :hook (after-init . show-paren-mode)
  :init
  (setq show-paren-delay 0.1)
  (setq show-paren-when-point-inside-paren t
        show-paren-when-point-in-periphery t)
  (setq show-paren-style 'parenthesis) ;; parenthesis, expression
  (set-face-attribute 'show-paren-match nil :weight 'extra-bold))

(electric-pair-mode 1)
(setq electric-pair-pairs
      '(
        (?\" . ?\")
        (?\{ . ?\})))
(setq electric-pair-preserve-balance t
      electric-pair-delete-adjacent-pairs t
      electric-pair-skip-self 'electric-pair-default-skip-self
      electric-pair-open-newline-between-pairs t)

(use-package project
  :custom
  (project-switch-commands
   '(
     (consult-project-buffer "buffer" ?b)
     (project-dired "dired" ?d)
     (magit-project-status "magit status" ?g)
     (project-find-file "find file" ?p)
     (consult-ripgrep "rigprep" ?r)
     (vterm-toggle-cd "vterm" ?t)))
  (project-vc-merge-submodules nil)
  :config
  ;; project-find-file 忽略的目录或文件列表。
  (add-to-list 'vc-directory-exclusion-list "vendor") ;; go
  (add-to-list 'vc-directory-exclusion-list "node_modules") ;; node
  (add-to-list 'vc-directory-exclusion-list "target") ;; rust
  )

(defun my/project-try-local (dir)
  "Determine if DIR is a non-Git project."
  (catch 'ret
    (let ((pr-flags '(
		      ;; 顺着目录 top-down 查找第一个匹配的文件。所以中间目录不能有
		      ;; .project 等文件，否则判断 project root 错误。
		      ("go.mod" "Cargo.toml" "pom.xml" "package.json" ".project" )
                      ;; 以下文件容易导致 project root 判断错误, 故不添加。
                      ;; ("Makefile" "README.org" "README.md")
                      )))
      (dolist (current-level pr-flags)
        (dolist (f current-level)
          (when-let ((root (locate-dominating-file dir f)))
            (throw 'ret (cons 'local root))))))))
(setq project-find-functions '(my/project-try-local project-try-vc))

(cl-defmethod project-root ((project (head local)))
  (cdr project))

(defun my/project-discover ()
  (interactive)
  ;; 去掉 "~/go/src/k8s.io/*" 目录。
  (dolist (search-path
	   '("~/go/src/github.com/*"
	     "~/go/src/github.com/*/*"
	     "~/go/src/gitlab.*/*/*"))
    (dolist (file (file-expand-wildcards search-path))
      (when (file-directory-p file)
        (message "dir %s" file)
        ;; project-remember-projects-under 列出 file 下的目录, 分别加到
        ;; project-list-file 中。
        (project-remember-projects-under file nil)
        (message "added project %s" file)))))

;; 不将 tramp 项目记录到 projects 文件中，防止 emacs-dashboard 启动时检查 project 卡
;; 住。
(defun my/project-remember-advice (fn pr &optional no-write)
  (let* ((remote? (file-remote-p (project-root pr)))
         (no-write (if remote? t no-write)))
    (funcall fn pr no-write)))
(advice-add 'project-remember-project :around 'my/project-remember-advice)

(setq vc-follow-symlinks t)

;; 自动 revert buffer，确保 modeline 上的分支名正确。
(setq auto-revert-check-vc-info t)

(use-package magit
  :custom
  ;; 在当前 window 中显示 magit buffer。
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  (magit-log-arguments '("-n256" "--graph" "--decorate" "--color"))
  ;; 按照 word 展示 diff。
  (magit-diff-refine-hunk t)
  (magit-clone-default-directory "~/go/src/")
  :config
  ;; diff org-mode 时展开内容。
  (add-hook 'magit-diff-visit-file-hook (lambda() (when (derived-mode-p 'org-mode)(org-fold-show-entry)))))

(use-package git-link
  :config
  (setq git-link-use-commit t)
  ;; 重写 gitlab 的 format 字符串以匹配内部系统。
  (defun git-link-commit-gitlab (hostname dirname commit)
    (format "https://%s/%s/commit/%s" hostname dirname commit))
  (defun git-link-gitlab (hostname dirname filename branch commit start end)
    (format "https://%s/%s/blob/%s/%s" hostname dirname
	    (or branch commit)
            (concat filename
                    (when start
                      (concat "#"
                              (if end
                                  (format "L%s-%s" start end)
				(format "L%s" start))))))))

(use-package treesit-auto
  :demand t
  :config
  (setq treesit-auto-install 'prompt)
  (global-treesit-auto-mode))

(use-package treesit-fold
  :vc (:url "https://github.com/emacs-tree-sitter/treesit-fold")
  :config
  (global-set-key (kbd "C-c f f") 'treesit-fold-close)
  (global-set-key (kbd "C-c f o") 'treesit-fold-open)
  (global-set-key (kbd "C-c f O") 'treesit-fold-open-recursively)
  (global-set-key (kbd "C-c f F") 'treesit-fold-close-all)
  (global-set-key (kbd "C-c f u") 'treesit-fold-open-all)
  (global-set-key (kbd "C-c f t") 'treesit-fold-toggle))

(use-package flymake
  :config
  ;; 不自动检查 buffer 错误。
  (setq flymake-no-changes-timeout nil)

  ;; 在行尾显示诊断消息（Emacs 30 开始支持）, 'short 只显示一条最重要信息，t 显示所有
  ;; 信息。
  (setq flymake-show-diagnostics-at-end-of-line 'short)

  ;; 如果 buffer 出现错误的诊断消息，执行 flymake-start 重新触发诊断。
  (define-key flymake-mode-map (kbd "C-c C-c") #'flymake-start)

  ;; 显示诊断错误列表
  (global-set-key (kbd "C-s-l") #'consult-flymake)
  (define-key flymake-mode-map (kbd "C-s-n") #'flymake-goto-next-error)
  (define-key flymake-mode-map (kbd "C-s-p") #'flymake-goto-prev-error))

;; 解决 flymake-no-changes-timeout 为 nil 时诊断延迟的问题。
;;; https://github.com/joaotavora/eglot/issues/1296
;; (cl-defmethod eglot-handle-notification :after
;;   (_server (_method (eql textDocument/publishDiagnostics)) &key uri
;;            &allow-other-keys)
;;   (when-let ((buffer (find-buffer-visiting (eglot-uri-to-path uri))))
;;     (with-current-buffer buffer
;;       (if (and (eq nil flymake-no-changes-timeout)
;;                (not (buffer-modified-p)))
;;           (flymake-start t)))))

(use-package eglot
  :demand
  :after (flymake)
  :preface
  (defun my/eglot-eldoc ()
    ;; eglot will change the completion-category-defaults to flex, BAD!
    ;; https://github.com/minad/corfu/issues/136#issuecomment-eglot
    ;; 这里将 completion-category-defaults 设置为 nil，然后在 completion-category-overrides
    ;; 中设置 eglot 使用 orderless 补全风格。
    (setq completion-category-defaults nil)

    ;; 在 eldoc buffer 开始优先显示 flymake 诊断信息。
    (setq eldoc-documentation-functions
          (cons #'flymake-eldoc-function
                (remove #'flymake-eldoc-function eldoc-documentation-functions)))
    )
  :hook ((eglot-managed-mode . my/eglot-eldoc))
  :bind
  (:map eglot-mode-map
        ("C-c C-a" . eglot-code-actions)
        ("C-c C-f" . eglot-format-buffer)
        ("C-c C-r" . eglot-rename)
	("C-c C-c" . flymake-start)
	("C-c C-d" . eldoc))
  :config
  ;; 将 eglot-events-buffer-size 设置为 0 后将关闭显示 *EGLOT event* bufer，不便于调
  ;; 试问题。也不能设置的太大，否则可能影响性能。
  (setq eglot-events-buffer-size (* 1024 1024 1))

  ;; 将 flymake-no-changes-timeout 设置为 nil 后，eglot 保存 buffer 内容后，经过 idle
  ;; time 才会向LSP 发送诊断请求。
  (setq eglot-send-changes-idle-time 0.1)

  ;; 当最后一个源码 buffer 关闭时自动关闭 eglot server。
  (customize-set-variable 'eglot-autoshutdown t)
  (customize-set-variable 'eglot-connect-timeout 60)

  ;;不给所有 prog-mode 都开启 eglot，否则当它没有 language server 时 eglot 报错。
  ;;
  ;;由于 treesit-auto 已经对 major-mode 做了 remap ，需要对 xx-ts-mode-hook 添加 hook，
  ;;而不是以前的 xx-mode-hook, 否则添加到 xx-mode-hook 的内容不会被自动执行。
  (add-hook 'c-ts-mode-hook #'eglot-ensure)
  (add-hook 'go-ts-mode-hook #'eglot-ensure)
  (add-hook 'bash-ts-mode-hook #'eglot-ensure)
  (add-hook 'python-mode-hook #'eglot-ensure)
  (add-hook 'python-ts-mode-hook #'eglot-ensure)
  (add-hook 'rust-ts-mode-hook #'eglot-ensure)
  (add-hook 'rust-mode-hook #'eglot-ensure)
  (add-hook 'yaml-mode-hook #'eglot-ensure)
  (add-hook 'yaml-ts-mode-hook #'eglot-ensure)

  (setq eglot-ignored-server-capabilities
        '(
          ;;:hoverProvider ;; 显示光标位置信息。
          ;;:documentHighlightProvider ;; 高亮当前 symbol。
          ;;:inlayHintProvider ;; 显示 inlay hint 提示。
          ))

  ;; 加强高亮的 symbol 效果。
  ;;(set-face-attribute 'eglot-highlight-symbol-face nil :background "#b3d7ff")

  ;; t: true, false: :json-false(不是 nil)。
  ;; gopls 配置参数: https://github.com/golang/tools/blob/master/gopls/doc/settings.setq
  (setq-default eglot-workspace-configuration
                '((:gopls . ((staticcheck . t)
                             (usePlaceholders . :json-false)
                             ;; gopls 默认设置 GOPROXY=Off, 可能会导致 package 缺失进
                             ;; 而引起补全异常. 开启 allowImplicitNetworkAccess 后将
                             ;; 关闭 GOPROXY=Off.
                             ;;(allowImplicitNetworkAccess . t)
                             )))))

(use-package consult-eglot
  :after (eglot consult))

(use-package eglot-booster
  :vc (:url "https://github.com/jdtsmith/eglot-booster")
  :after (eglot)
  :config (eglot-booster-mode))

(use-package eldoc
  :after (eglot)
  :bind
  (:map eglot-mode-map ("C-c C-d" . eldoc))
  :config
  (setq eldoc-idle-delay 0.1)

  ;; 打开 eldoc-buffer 时关闭 echo-area 显示, eldoc-buffer 会跟随显示 hover 信息, 如
  ;; 函数签名。
  (setq eldoc-echo-area-prefer-doc-buffer t)

  ;; 在屏幕右侧显示 eldoc-buffer
  (add-to-list 'display-buffer-alist
               '("^\\*eldoc.*\\*"
                 (display-buffer-reuse-window display-buffer-in-side-window)
                 (dedicated . t)
                 (side . right)
                 (inhibit-same-window . t)))

  ;; 将 minibuffer 窗口高度设为 1，可以确保只显示一行（默认为小数，表示 frame 高度占
  ;; 比，会导致显示多行）。
  (setq max-mini-window-height 1)
  ;; 为 nil 时只单行显示 eldoc 信息.
  (setq eldoc-echo-area-use-multiline-p nil)

  ;; 一键显示和关闭 eldoc buffer。
  (global-set-key (kbd "M-`")
                  (lambda()
                    (interactive)
                    (if (get-buffer-window "*eldoc*")
			(delete-window (get-buffer-window "*eldoc*"))
                      (display-buffer "*eldoc*")))))

(use-package eldoc-box
  :after (eglot eldoc)
  :bind
  (:map eglot-mode-map
        ("C-M-k" . (lambda () (interactive) (eldoc-box-scroll-down 1)))
        ("C-M-j" . (lambda () (interactive) (eldoc-box-scroll-up 1)))
	;; 按需弹出 posframe 来显示 eldoc buffer 内容。
	("C-c C-d" . eldoc-box-help-at-point)
	)

  :config
  (setq eldoc-box-max-pixel-height 600)
  (setq eldoc-box-max-pixel-width 1200)

  ;; C-g 关闭弹出的 child frame。
  (setq eldoc-box-clear-with-C-g t)

  ;; 在右上角显示 eldoc 帮助；
  ;;(add-hook 'eglot-managed-mode-hook #'eldoc-box-hover-mode t)

  ;; 在光标位置显示 eldoc 帮助；
  ;;(add-hook 'eglot-managed-mode-hook #'eldoc-box-hover-at-point-mode t)
  )

;; 将 ~/.venv/bin 添加到 PATH 环境变量和 exec-path 变量中。
(setq my-venv-path "/Users/alizj/.venv/bin")
(setenv "PATH" (concat my-venv-path ":" (getenv "PATH")))
(setq exec-path (cons my-venv-path  exec-path))

;; 指定 python.el 使用虚拟环境目录。
(setq python-shell-virtualenv-root "/Users/alizj/.venv")

(defun my/python-setup-shell (&rest args)
  (if (executable-find "ipython3")
      (progn
        ;; 使用 ipython3 作为 python shell.
        (setq python-shell-interpreter "ipython3")
        (setq python-shell-interpreter-args "--simple-prompt -i --InteractiveShell.display_page=True"))
    (progn
      ;; 查找 python-shell-virtualenv-root 中的解释器.
      (setq python-shell-interpreter "python3")
      (setq python-interpreter "python3")
      (setq python-shell-interpreter-args "-i"))))

;; 使用内置 python mode 和 LSP 来格式化代码（不适用 yapfify）
(use-package python
  :init
  ;;(setq python-indent-guess-indent-offset t)
  ;;(setq python-indent-guess-indent-offset-verbose nil)
  ;;(setq python-indent-offset 2)
  :hook
  (python-mode . (lambda ()
                   (my/python-setup-shell))))

(add-to-list 'eglot-server-programs
             '((python-mode python-ts-mode)
               "basedpyright-langserver" "--stdio"))

(require 'go-ts-mode)
;; go 使用 TAB 缩进。
(add-hook 'go-ts-mode-hook (lambda () (setq indent-tabs-mode t)))

(dolist (env '(("GOPATH" "/Users/alizj/go")
               ("GOPROXY" "https://goproxy.cn,https://goproxy.io,direct")
               ("GOPRIVATE" "*.alibaba-inc.com")
	       ("GOOS" "linux")
	       ("GOARCH" "arm64")))
  (setenv (car env) (cadr env)))

(require 'go-ts-mode)
;; 查看光标处符号的本地文档.
(define-key go-ts-mode-map (kbd "C-c d .") #'godoc-at-point)

;; 查看 go std 文档。
(defun my/browser-gostd ()
  (interactive)
  (xwidget-webkit-browse-url "https://pkg.go.dev/std"))
(define-key go-ts-mode-map (kbd "C-c d s") 'my/browser-gostd)

;; 搜索 pkg.go.dev 在线 web 文档。
(defun my/browser-pkggo (query)
  (interactive "ssearch: ")
  (xwidget-webkit-browse-url
   (concat "https://pkg.go.dev/search?q=" (string-replace " " "%20" query)) t))
(define-key go-ts-mode-map (kbd "C-c d w") 'my/browser-pkggo) ;; 助记: w -> web

;; (setq gofmt-command "golangci-lint")
;; (setq gofmt-args "run --config /Users/alizj/.golangci.yml --fix")

(defvar go--tools '("golang.org/x/tools/gopls"
                    "github.com/rogpeppe/godef"
                    "golang.org/x/tools/cmd/goimports"
                    "honnef.co/go/tools/cmd/staticcheck"
                    "github.com/go-delve/delve/cmd/dlv"
                    "github.com/zmb3/gogetdoc"
                    "github.com/josharian/impl"
                    "github.com/cweill/gotests/..."
                    "github.com/fatih/gomodifytags"
                    "github.com/golangci/golangci-lint/cmd/golangci-lint"
                    "github.com/davidrjenni/reftools/cmd/fillstruct"))

(defun go-update-tools ()
  (interactive)
  (unless (executable-find "go")
    (user-error "Unable to find `go' in `exec-path'!"))
  (message "Installing go tools...")
  (dolist (pkg go--tools)
    (set-process-sentinel
     (start-process "go-tools" "*Go Tools*" "go" "install" "-v" "-x" (concat pkg "@latest"))
     (lambda (proc _)))))

(use-package go-fill-struct)

(use-package go-impl)

;; 自动为 struct field 添加 json tag。
(use-package go-tag
  :init
  (setq go-tag-args (list "-transform" "camelcase"))
  :config
  (require 'go-ts-mode)
  (define-key go-ts-mode-map (kbd "C-c t a") #'go-tag-add)
  (define-key go-ts-mode-map (kbd "C-c t r") #'go-tag-remove))

(use-package go-playground
  :commands (go-playground-mode)
  :config
  (setq go-playground-init-command "go mod init"))

(setq my-cargo-path "/Users/alizj/.cargo/bin")
(setenv "PATH" (concat my-cargo-path ":" (getenv "PATH")))
(setq exec-path (cons my-cargo-path  exec-path))

;; https://github.com/mozilla/sccache?tab=readme-ov-file

;; cargo install sccache --locked
;;(setenv "RUSTC_WRAPPER" "/Users/alizj/.cargo/bin/sccache")

;; brew install sccache
(setenv "RUSTC_WRAPPER" "/opt/homebrew/bin/sccache")

;; https://github.com/jwiegley/dot-emacs/blob/master/init.org#rust-mode
(use-package rust-mode
  :after (eglot)
  :init
  (require 'rust-ts-mode)
  ;; rust-mode 作为 rust-ts-mode 而非 prog-mode 的子 mode。
  (setq rust-mode-treesitter-derive t)
  :config

  ;; rust-analyzer 使用 rustfmt 来格式化代码
  ;;(setq rust-format-on-save t)
  (setq rust-rustfmt-switches '("--edition" "2021"))

  ;; treesit-auto 默认不将 XX-mode-hook 添加到对应的 XX-ts-mode-hook 上, 需要手动指定。
  (setq rust-ts-mode-hook rust-mode-hook)

  ;; rust 建议使用空格而非 TAB 来缩进.
  (add-hook 'rust-ts-mode-hook (lambda () (setq indent-tabs-mode nil)))

  ;; 参数列表参考：https://rust-analyzer.github.io/manual.html#configuration
  (add-to-list
   'eglot-server-programs
   '((rust-ts-mode rust-mode) .
     ("rust-analyzer"
      :initializationOptions
      (
       :rustfmt
       (
	:extraArgs ["+nightly"]
	)
       ;; 20240910 不能关闭 checkOnSave，否则 flymake diagnose 可能不生效。
       ;;:checkOnSave :json-false
       ;;:cachePriming (:enable :json-false) ;; 启动时不预热缓存.
       :check
       (
        :command "clippy"
        ;;https://esp-rs.github.io/book/tooling/visual-studio-code.html#using-rust-analyzer-with-no_std
        :allTargets :json-false
	;; 不发送 --workspace 给 cargo check, 只检查当前 package.
	;; 20240910 可能导致基于 workspace 的 标准库 lsp 不生效，故不能设置。
        ;;:workspace :json-false
        )
       ;;:procMacro (:attributes (:enable t) :enable :json-false)
       :cargo
       (
        ;;:buildScripts (:enable :json-false)
        ;;:extraArgs ["--offline"] ;; 不联网节省时间.
        ;;:features "all"
        ;;:noDefaultFeatures t
        :cfgs (:tokio_unstable "")
        ;;:autoreload :json-false
        )
       :diagnostics
       (
	;;:enable :json-false
	:disabled ["unresolved-proc-macro" "unresolved-macro-call"]
	)
       :inlayHints
       (
	:bindingModeHints (:enable t)
	:closureCaptureHints (:enable t)
	:closureReturnTypeHints (:enable t)
	:lifetimeElisionHints (:enable t)
	:expressionAdjustmentHints (:enable t)
	)
       ;; :linkedProjects
       ;; [
       ;;  "/Users/alizj/.rustup/toolchains/stable-aarch64-apple-darwin/lib/rustlib/src/rust/library/std/Cargo.toml",
       ;;  "/Users/alizj/.rustup/toolchains/stable-aarch64-apple-darwin/lib/rustlib/src/rust/library/core/Cargo.toml",
       ;;  "/Users/alizj/.rustup/toolchains/stable-aarch64-apple-darwin/lib/rustlib/src/rust/library/proc_macro/Cargo.toml",
       ;;  "/Users/alizj/.rustup/toolchains/stable-aarch64-apple-darwin/lib/rustlib/src/rust/library/test/Cargo.toml"
       ;;  ]
       )))))

(use-package rust-playground
  :config
  (setq rust-playground-cargo-toml-template
        "[package]
name = \"foo\"
version = \"0.1.0\"
authors = [\"opsnull <geekard@qq.com>\"]
edition = \"2021\"

[dependencies]"))

(use-package eglot-x
  :after (eglot rust-mode)
  :vc (:url "https://github.com/nemethf/eglot-x")
  :init
  (require 'rust-ts-mode) ;; 绑定 rust-ts-mode-map 需要。
  :config
  (eglot-x-setup))

(with-eval-after-load 'rust-ts-mode
  ;; 使用 xwidget 打开光标处 symbol 的本地 crate 文档，由于是 web 网页，链接和类型都
  ;; 可以点击。
  (define-key rust-ts-mode-map (kbd "C-c d .") #'eglot-x-open-external-documentation)

  ;; 查看本地 rust std 文档;
  (defun my/browser-ruststd ()
    (interactive)
    (xwidget-webkit-browse-url "file:///Users/alizj/.rustup/toolchains/stable-aarch64-apple-darwin/share/doc/rust/html/std/index.html"  t))
  (define-key rust-ts-mode-map (kbd "C-c d s") 'my/browser-ruststd)

  ;; 在线 https:://docs.rs/ 搜索文档.
  (defun my/browser-docsrs (query)
    (interactive "ssearch: ")
    (xwidget-webkit-browse-url
     (concat "https://docs.rs/releases/search?query=" (string-replace " " "%20" query)) t))
  (define-key rust-ts-mode-map (kbd "C-c d w") 'my/browser-docsrs) ;; 助记: w -> web

  ;; 在线搜索 crate 包。
  (defun my/search-crates.io (query)
    (interactive "ssearch: ")
    (xwidget-webkit-browse-url
     (concat "https://crates.io/search?q=" (string-replace " " "%20" query)) t))
  (global-set-key (kbd "C-c d c") 'my/browser-docsrs) ;; 助记: c -> crates.io
  )

(use-package cargo-mode
  :after (rust-mode)
  :custom
  ;; cargo-mode 缺省为 compilation buffer 使用 comint mode, 设置为 nil 使用
  ;; compilation。
  (cargo-mode-use-comint nil)
  :hook
  (rust-ts-mode . cargo-minor-mode)
  :config
  ;; 自动滚动显示 compilation buffer 内容。
  (setq compilation-scroll-output t))

(use-package markdown-mode
  :commands (markdown-mode gfm-mode)
  :mode
  (("README\\.md\\'" . gfm-mode)
   ("\\.md\\'" . markdown-mode)
   ("\\.markdown\\'" . markdown-mode))
  :init
  (when (executable-find "multimarkdown")
    (setq markdown-command "multimarkdown"))
  (setq markdown-enable-wiki-links t)
  (setq markdown-italic-underscore t)
  (setq markdown-asymmetric-header t)
  (setq markdown-make-gfm-checkboxes-buttons t)
  (setq markdown-gfm-uppercase-checkbox t)
  (setq markdown-fontify-code-blocks-natively t)
  (setq markdown-gfm-additional-languages "Mermaid")
  (setq markdown-content-type "application/xhtml+xml")
  (setq markdown-css-paths
	'("https://cdn.jsdelivr.net/npm/github-markdown-css/github-markdown.min.css"
          "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release/build/styles/github.min.css"))
  (setq markdown-xhtml-header-content "
<meta name='viewport' content='width=device-width, initial-scale=1, shrink-to-fit=no'>
<style>
body {
  box-sizing: border-box;
  max-width: 740px;
  width: 100%;
  margin: 40px auto;
  padding: 0 10px;
}
</style>
<link rel='stylesheet' href='https://cdn.jsdelivr.net/gh/highlightjs/cdn-release/build/styles/default.min.css'>
<script src='https://cdn.jsdelivr.net/gh/highlightjs/cdn-release/build/highlight.min.js'></script>
<script>
document.addEventListener('DOMContentLoaded', () => {
  document.body.classList.add('markdown-body');
  document.querySelectorAll('pre code').forEach((code) => {
    if (code.className != 'mermaid') {
      hljs.highlightBlock(code);
    }
  });
});
</script>
<script src='https://unpkg.com/mermaid@8.4.8/dist/mermaid.min.js'></script>
<script>
mermaid.initialize({
  theme: 'default',  // default, forest, dark, neutral
  startOnLoad: true
});
</script>
"))

(use-package grip-mode
  :defer
  :after (markdown-mode)
  :config
  (setq grip-preview-use-webkit nil)
  (setq grip-preview-host "127.0.0.1")
  ;; 保存文件时才更新预览。
  (setq grip-update-after-change nil)
  ;; 从 ~/.authinfo 文件获取认证信息。
  (require 'auth-source)
  (let ((credential (auth-source-user-and-password "api.github.com")))
    (setq grip-github-user (car credential)
          grip-github-password (cadr credential)))
  (define-key markdown-mode-command-map (kbd "g") #'grip-mode))

(use-package markdown-toc
  :after(markdown-mode)
  :config
  (define-key markdown-mode-command-map (kbd "r") #'markdown-toc-generate-or-refresh-toc))

(setq sh-basic-offset 4)
(setq sh-indentation 4)

(setq my-llvm-path "/opt/homebrew/opt/llvm/bin")
(setenv "PATH" (concat my-llvm-path ":" (getenv "PATH")))
(setq exec-path (cons my-llvm-path  exec-path))

(use-package tempel
  :bind
  (("M-+" . tempel-complete)
   ("M-*" . tempel-insert))
  :init
  ;; 自定义模板文件。
  (setq tempel-path "/Users/alizj/emacs/templates")
  (add-hook 'conf-mode-hook 'tempel-setup-capf)
  (add-hook 'prog-mode-hook 'tempel-setup-capf)
  (add-hook 'text-mode-hook 'tempel-setup-capf)

  (defun tempel-setup-capf ()
    (setq-local completion-at-point-functions (cons #'tempel-expand completion-at-point-functions)))
  ;; 确保 tempel-setup-capf 位于 eglot-managed-mode-hook 前，这样 corfu 才会显示
  ;; tempel 的自动补全。
  ;; https://github.com/minad/tempel/issues/103#issuecomment-1543510550
  (add-hook #'eglot-managed-mode-hook 'tempel-setup-capf))

(use-package tempel-collection)

;; https://gitlab.com/skybert/my-little-friends/-/blob/master/emacs/.emacs#L295
(setq compilation-ask-about-save nil
      compilation-always-kill t
      compilation-scroll-output 'first-error ;; 滚动显示到第一个出错位置。
      compilation-context-lines 10
      compilation-skip-threshold 2
      ;;compilation-window-height 100
      )

(define-key compilation-mode-map (kbd "q") 'delete-window)

;; 显示 shell 转义字符的颜色。
(add-hook 'compilation-filter-hook
          (lambda ()
	    (ansi-color-apply-on-region (point-min) (point-max))))

;; 编译结束且失败时自动切换到 compilation buffer。
(setq compilation-finish-functions
      (lambda (buf str)
        (if (null (string-match ".*exited abnormally.*" str))
            ;; 没有错误, 什么也不做。
            nil
          ;; 有错误时切换到 compilation buffer。
          (switch-to-buffer-other-window buf)
          (end-of-buffer))))

(setenv "GTAGSOBJDIRPREFIX" (expand-file-name "~/.cache/gtags/"))
(setenv "GTAGSCONF" (car (file-expand-wildcards "/opt/homebrew/opt/global/share/gtags/gtags.conf")))
(setenv "GTAGSLABEL" "pygments")

(use-package citre
  :after (eglot)
  :config
  ;; 只使用支持 reference 的 GNU Global tags。
  (setq citre-completion-backends '(global))
  (setq citre-find-definition-backends '(global))
  (setq citre-find-reference-backends '(global))
  (setq citre-tags-in-buffer-backends  '(global))
  (setq citre-auto-enable-citre-mode-backends '(global))
  (setq citre-use-project-root-when-creating-tags t)
  (setq citre-peek-file-content-height 20)

  ;; 打开列表中的 major mode 文件且项目具有 global tags 文件时，才自动开启 citre。
  (setq citre-auto-enable-citre-mode-modes
	'(
	  c-mode
	  c-ts-mode
	  rust-mode
	  rust-ts-mode
	  ;; go-mode
	  ;; go-ts-mode
	  ))

  ;; 使用 eglot-managed-mode-hook 而非 find-file-hook，从而确保 citre-mode 在 eglot
  ;; 启动后才开启。

  ;; 执行 citre-auto-enable-citre-mode 而非 citre-mode 命令：

  ;; 1. 前者会检查 citre-auto-enable-citre-mode-modes 变量中的 major mode 和项目是否
  ;; 有 global tags文件，只有两者均满足时，才开启 citre。

  ;; 2. 后者是不管 major mode 类型和是否有 tags 文件，均开启 citre。
  (add-hook 'eglot-managed-mode-hook #'citre-auto-enable-citre-mode)

  (define-key citre-mode-map (kbd "s-.") 'citre-jump)
  (define-key citre-mode-map (kbd "s-,") 'citre-jump-back)
  (define-key citre-mode-map (kbd "s-?") 'citre-peek-reference)
  (define-key citre-mode-map (kbd "s-p") 'citre-peek)
  (define-key citre-peek-keymap (kbd "s-n") 'citre-peek-next-line)
  (define-key citre-peek-keymap (kbd "s-p") 'citre-peek-prev-line)
  (define-key citre-peek-keymap (kbd "s-N") 'citre-peek-next-tag)
  (define-key citre-peek-keymap (kbd "s-P") 'citre-peek-prev-tag))

(use-package gptel
  :ensure t
  :config
  (setq
   gptel-default-mode 'org-mode
   gptel-model 'gpt-4o
   gptel-backend
   (gptel-make-azure "Azure"         
     :protocol "https"
     :host "westus3ai.openai.azure.com"
     :endpoint "/openai/deployments/4fouro/chat/completions?api-version=2024-02-15-preview"
     :stream t        
     :key #'gptel-api-key
     :models '(gpt-4o))))

(use-package vterm
  :hook
  (vterm-mode . (lambda ()
		  ;; 关闭一些 mode，提升显示性能。
		  (setf truncate-lines nil)
		  (setq-local show-paren-mode nil)
		  (setq-local global-hl-line-mode nil)
	          (display-line-numbers-mode -1) ;; 不显示行号。
		  ;;; vterm buffer 使用 fixed pitch 的 mono 字体，否则部分终端表格之
		  ;;; 类的程序会对不齐。
		  (set (make-local-variable 'buffer-face-mode-face) 'fixed-pitch)
		  (buffer-face-mode t)))
  :config
  (setq vterm-set-bold-hightbright t)
  (setq vterm-always-compile-module t)
  (setq vterm-max-scrollback 100000)
  (setq vterm-timer-delay 0.01) ;; nil: no delay
  (add-to-list 'vterm-tramp-shells '("ssh" "/bin/bash"))
  ;; vterm buffer 名称，%s 为 shell 的 PROMPT_COMMAND 变量的输出。
  (setq vterm-buffer-name-string "*vt: %s")
  ;; 使用 M-y(consult-yank-pop) 粘贴剪贴板历史中的内容。
  (define-key vterm-mode-map [remap consult-yank-pop] #'vterm-yank-pop)
  (define-key vterm-mode-map (kbd "C-l") nil)
  ;; 防止输入法切换冲突。
  (define-key vterm-mode-map (kbd "C-\\") nil))

(use-package multi-vterm
  :after (vterm)
  :config
  (define-key vterm-mode-map  [(control return)] #'multi-vterm))

(use-package vterm-toggle
  :after (vterm)
  :custom
  ;; 由于 TRAMP 模式下关闭了 projectile，scope 不能设置为 'project。
  ;;(vterm-toggle-scope 'dedicated)
  (vterm-toggle-scope 'project)
  :config
  (global-set-key (kbd "C-`") 'vterm-toggle)
  (global-set-key (kbd "C-M-`") 'vterm-toggle-cd)
  (define-key vterm-mode-map (kbd "M-RET") #'vterm-toggle-insert-cd)
  ;; 切换到空闲的 vterm buffer 并插入一个 cd 命令，或者创建一个新的 vterm buffer。
  (define-key vterm-mode-map (kbd "M-i") 'vterm-toggle-cd-show)
  (define-key vterm-mode-map (kbd "M-n") 'vterm-toggle-forward)
  (define-key vterm-mode-map (kbd "M-p") 'vterm-toggle-backward)
  (define-key vterm-copy-mode-map (kbd "M-i") 'vterm-toggle-cd-show)
  (define-key vterm-copy-mode-map (kbd "M-n") 'vterm-toggle-forward)
  (define-key vterm-copy-mode-map (kbd "M-p") 'vterm-toggle-backward))

(use-package vterm-extra
  :vc (:url "https://github.com/Sbozzolo/vterm-extra")
  :config
  (define-key vterm-mode-map (kbd "C-c C-e") #'vterm-extra-edit-command-in-new-buffer))

(setq eshell-history-size 300)
(setq explicit-shell-file-name "/bin/bash")
(setq shell-file-name "/bin/bash")
(setq shell-command-prompt-show-cwd t)
(setq explicit-bash-args '("--noediting" "--login" "-i"))
;; 提示符只读
(setq comint-prompt-read-only t)
;; 命令补全
(setq shell-command-completion-mode t)
;; 高亮模式
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on t)
(setenv "SHELL" shell-file-name)
(setenv "ESHELL" "bash")
(add-hook 'comint-output-filter-functions 'comint-strip-ctrl-m)

;; 在当前 frame 下方打开或关闭 eshell buffer。
(defun startup-eshell ()
  "Fire up an eshell buffer or open the previous one"
  (interactive)
  (if (get-buffer-window "*eshell*<42>")
      (delete-window (get-buffer-window "*eshell*<42>"))
    (progn
      (eshell 42))))
(global-set-key (kbd "s-`") 'startup-eshell)

(add-to-list 'display-buffer-alist
	     '("\\*eshell\\*<42>"
	       (display-buffer-below-selected display-buffer-at-bottom)
	       (inhibit-same-window . t)
	       (window-height . 0.33)))

;; eshell history 使用 consult-history。
(load-library "em-hist.el")
(keymap-set eshell-hist-mode-map "C-s" #'consult-history)
(keymap-set eshell-hist-mode-map "C-r" #'consult-history)
;; 重置 M-r/s 快捷键，这样 consult-line 等可用。
(define-key eshell-hist-mode-map (kbd "M-r") nil)
(define-key eshell-hist-mode-map (kbd "M-s") nil)

;; 避免 undo-more: No further undo information 报错.
;; 10X bump of the undo limits to avoid issues with premature.
;; Emacs GC which truncages the undo history very aggresively
(setq undo-limit 800000)
(setq undo-strong-limit 12000000)
(setq undo-outer-limit 120000000)

(global-auto-revert-mode 1)
(setq revert-without-query (list "\\.png$" "\\.svg$")
      auto-revert-verbose nil)

(setq global-mark-ring-max 600)
(setq mark-ring-max 600)
(setq kill-ring-max 600)

(use-package emacs
  :init
  ;; 粘贴于光标处, 而不是鼠标指针处。
  (setq mouse-yank-at-point t)
  (setq initial-major-mode 'fundamental-mode)
  ;; 按中文折行。
  (setq word-wrap-by-category t)
  ;; 退出自动杀掉进程。
  (setq confirm-kill-processes nil)
  (setq use-short-answers t)
  (setq confirm-kill-emacs #'y-or-n-p)
  (setq ring-bell-function 'ignore)
  ;; 不显示行号, 否则鼠标会飘。
  (add-hook 'artist-mode-hook (lambda () (display-line-numbers-mode -1)))
  ;; bookmark 发生变化时自动保存（默认是 Emacs 正常退出时保存）。
  (setq bookmark-save-flag 1)
  ;; 不创建 lock 文件。
  (setq create-lockfiles nil)
  ;; 启动 Server 。
  (unless (and (fboundp 'server-running-p)
               (server-running-p))
    (server-start)))

(use-package hydra :commands defhydra)

(use-package recentf
  :config
  (setq recentf-save-file "~/.emacs.d/recentf")

  ;; 自动清理 recentf 记录（无效的、重复的、被 exclude 的等），防止已经删除的文件继续
  ;; 出现在 consult-buffer 列表中
  (setq recentf-auto-cleanup 'mode)

  ;; 每 5min 以及 emacs 退出时保存 recentf-list。
  ;; 20241017: 配置这两个参数后，recentf 将被清空。
  ;;(run-at-time nil (* 5 60) 'recentf-save-list)
  ;;(add-hook 'kill-emacs-hook #'recentf-save-list)

  (setq recentf-max-menu-items 100)
  (setq recentf-max-saved-items 100)

  ;; recentf-exclude 的参数是正则表达式列表，不支持 ~ 引用家目录。
  ;;; emacs-dashboard 不显示这里排除的文件。
  (setq recentf-exclude
	`(
	  ,(recentf-expand-file-name "~/.emacs.d/\\(straight\\|ln-cache\\|etc\\|var\\|.cache\\|backup\\|elfeed\\)/.*")
          ,(recentf-expand-file-name "~/.emacs.d/\\(recentf\\|bookmarks\\|archived.org\\)")
	  ,(recentf-expand-file-name "~/go/mod/.*")
	  ;; 不在 recentf 中记录 tramp 文件，防止 tramp 扫描时卡住。
          ,tramp-file-name-regexp
          "^/tmp"
	  "\\.bak\\'"
	  "\\.gpg\\'"
	  "\\.gz\\'"
	  "\\.tgz\\'"
	  "\\.xz\\'"
	  "\\.zip\\'"
	  "^/ssh:"
	  "\\.png\\'"
          "\\.jpg\\'"
	  "/\\.git/"
	  "\\.gitignore\\'"
	  "\\.log\\'"
	  "COMMIT_EDITMSG"
	  "\\.pyi\\'"
	  "\\.pyc\\'"
          "/private/var/.*"
	  "^/usr/local/Cellar/.*"
	  ".*/vendor/.*"
	  ".*/target/.*"
	  "/Applications/.*"
          ,(concat package-user-dir "/.*-autoloads\\.egl\\'")))
  (recentf-mode 1))

;; dired
(setq my-coreutils-path "/opt/homebrew/opt/coreutils/libexec/gnubin")
(setenv "PATH" (concat my-coreutils-path ":" (getenv "PATH")))
(setq exec-path (cons my-coreutils-path  exec-path))

(use-package emacs
  :config
  (setq dired-dwim-target t)
  ;; @see
  ;; https://emacs.stackexchange.com/questions/5649/sort-file-names-numbered-in-dired/5650#5650
  ;; 下面的参数只对安装了 coreutils (brew install coreutils) 的包有效，否则会报错。
  (setq dired-listing-switches "-laGh1v --group-directories-first"))

(use-package diredfl :config (diredfl-global-mode))

(use-package grep
  :config
  (setq grep-highlight-matches t)
  (setq grep-find-ignored-directories
        (append (list ".git" ".cache" "vendor" "node_modules" "target")
                grep-find-ignored-directories))
  (setq grep-find-ignored-files
        (append (list "*.blob" "*.gz" "TAGS" "projectile.cache" "GPATH" "GRTAGS" "GTAGS" "TAGS" ".project" )
                grep-find-ignored-files)))

(global-set-key "\C-cn" 'find-dired)
(global-set-key "\C-cN" 'grep-find)

(setq isearch-allow-scroll 'unlimited)
;; 显示当前和总的数量。
(setq isearch-lazy-count t)
(setq isearch-lazy-highlight t)

;; diff
(use-package diff-mode
  :init
  (setq diff-default-read-only t)
  (setq diff-advance-after-apply-hunk t)
  (setq diff-update-on-the-fly t))

(use-package ediff
  :config
  (setq ediff-keep-variants nil)
  (setq ediff-split-window-function 'split-window-horizontally)
  ;; 不创建新的 frame 来显示 Control-Panel。
  (setq ediff-window-setup-function #'ediff-setup-windows-plain))

;; 使用系统剪贴板，实现与其它程序相互粘贴。
(setq x-select-enable-clipboard t)
(setq select-enable-clipboard t)
(setq x-select-enable-primary t)
(setq select-enable-primary t)

;; UTF8 字符。
(prefer-coding-system 'utf-8)
(setq locale-coding-system 'utf-8
      default-buffer-file-coding-system 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(set-language-environment "UTF-8")
(setq-default buffer-file-coding-system 'utf8)
(set-default-coding-systems 'utf-8)
(setenv "LC_ALL" "zh_CN.UTF-8")

(use-package ibuffer
  :config
  (setq ibuffer-expert t)
  (setq ibuffer-use-other-window nil)
  (setq ibuffer-movement-cycle nil)
  (setq ibuffer-default-sorting-mode 'recency)
  (setq ibuffer-use-header-line t)
  (add-hook 'ibuffer-mode-hook #'hl-line-mode)
  (global-set-key (kbd "C-x C-b") #'ibuffer))

;; 保存 Buffer 时自动更新 #+LASTMOD: 时间戳。
(setq time-stamp-start "#\\+\\(LASTMOD\\|lastmod\\):[ \t]*")
(setq time-stamp-end "$")
(setq time-stamp-format "%Y-%m-%dT%02H:%02m:%02S%5z")
;; #+LASTMOD: 必须位于文件开头的 line-limit 行内, 否则自动更新不生效。
(setq time-stamp-line-limit 30)
(add-hook 'before-save-hook 'time-stamp t)

;; 以下自定义函数参考自：https://github.com/jiacai2050/dotfiles/blob/master/.config/emacs/i-edit.el
(defun my/json-format ()
  (interactive)
  (save-excursion
    (if mark-active
        (json-pretty-print (mark) (point))
      (json-pretty-print-buffer))))

(defun my/delete-file-and-buffer (buffername)
  "Delete the file visited by the buffer named BUFFERNAME."
  (interactive "bDelete file")
  (let* ((buffer (get-buffer buffername))
         (filename (buffer-file-name buffer)))
    (when filename
      (delete-file filename)
      (message "Deleted file %s" filename)
      (kill-buffer))))

(defun my/diff-buffer-with-file ()
  "Compare the current modified buffer with the saved version."
  (interactive)
  (let ((diff-switches "-u")) ;; unified diff
    (diff-buffer-with-file (current-buffer))
    (other-window 1)))

(defun my/copy-current-filename-to-clipboard ()
  "Copy `buffer-file-name' to system clipboard."
  (interactive)
  (let ((filename (if-let (f buffer-file-name)
                      f
                    default-directory)))
    (if filename
        (progn
          (message (format "Copying %s to clipboard..." filename))
          (kill-new filename))
      (message "Not a file..."))))

;; https://gitlab.com/skybert/my-little-friends/-/blob/2022-emacs-from-scratch/emacs/.emacs
;; Rename current buffer, as well as doing the related version control commands to
;; rename the file.
(defun my/rename-this-buffer-and-file ()
  "Renames current buffer and file it is visiting."
  (interactive)
  (let ((filename (buffer-file-name)))
    (if (not (and filename (file-exists-p filename)))
        (message "Buffer is not visiting a file!")
      (let ((new-name (read-file-name "New name: " filename)))
        (cond
         ((vc-backend filename) (vc-rename-file filename new-name))
         (t
          (rename-file filename new-name t)
          (rename-buffer new-name)
          (set-visited-file-name new-name)
          (set-buffer-modified-p nil)
          (message
           "File '%s' successfully renamed to '%s'"
           filename
           (file-name-nondirectory new-name))))))))
(global-set-key (kbd "C-x C-r") 'my/rename-this-buffer-and-file)

(use-package mwim
  :config
  (define-key global-map [remap move-beginning-of-line] #'mwim-beginning-of-code-or-line)
  (define-key global-map [remap move-end-of-line] #'mwim-end-of-code-or-line))

(use-package expand-region
  :config
  (global-set-key (kbd "C-=") #'er/expand-region))

(defvar backup-dir (expand-file-name "~/.emacs.d/backup/"))
(if (not (file-exists-p backup-dir))
    (make-directory backup-dir t))
;; 文件第一次保存时备份。
(setq make-backup-files t)
(setq backup-by-copying t)
;; 不备份 tramp 文件，其它文件都保存到 backup-dir, https://stackoverflow.com/a/22077775
(setq backup-directory-alist `((,tramp-file-name-regexp . nil) (".*" . ,backup-dir)))
;; 备份文件时使用版本号。
(setq version-control t)
;; 删除过多的版本。
(setq delete-old-versions t)
(setq kept-new-versions 6)
(setq kept-old-versions 2)
;; 不备份版本控制的文件.
(setq vc-make-backup-files nil)

(defvar autosave-dir (expand-file-name "~/.emacs.d/autosave/"))
(if (not (file-exists-p autosave-dir))
    (make-directory autosave-dir t))

;; auto-save 访问的文件。
(setq auto-save-default t)
(setq auto-save-list-file-prefix autosave-dir)
(setq auto-save-file-name-transforms `((".*" ,autosave-dir t)))
(setq kill-buffer-delete-auto-save-files t)
(setq auto-save-include-big-deletions t)

(setq url-user-agent
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36")
(setq xwidget-webkit-buffer-name-format "*webkit* [%T] - %U")
(setq xwidget-webkit-enable-plugins t)
(setq browse-url-firefox-program "/Applications/Firefox.app/Contents/MacOS/firefox")
;; browse-url-firefox, browse-url-default-macosx-browser
(setq browse-url-browser-function 'xwidget-webkit-browse-url)
(setq xwidget-webkit-cookie-file "~/.emacs.d/cookie.txt")

(add-hook 'xwidget-webkit-mode-hook
          (lambda ()
            ;;(setq kill-buffer-query-functions nil)
            (setq header-line-format nil)
            (display-line-numbers-mode 0)
            ;;(local-set-key "q" (lambda () (interactive) (kill-this-buffer)))
            (local-set-key (kbd "C-t") (lambda () (interactive) (xwidget-webkit-browse-url "https://google.com" t)))))

(defun my/browser-open-at-point (url)
  (interactive
   (list (let ((url (thing-at-point 'url)))
           (if (equal major-mode 'xwidget-webkit-mode)
               (read-string "url: " (xwidget-webkit-uri (xwidget-webkit-current-session)))
             (read-string "url: " url)))))
  (xwidget-webkit-browse-url url t))

(defun my/browser-search (query)
  (interactive "ssearch: ")
  (xwidget-webkit-browse-url
   (concat "https://duckduckgo.com?q=" (string-replace " " "%20" query)) t))

(define-prefix-command 'my-browser-prefix)
(global-set-key (kbd "C-c o") 'my-browser-prefix)
(define-key my-browser-prefix (kbd "o") 'my/browser-open-at-point)
(define-key my-browser-prefix (kbd "s") 'my/browser-search)

;; https://github.com/syl20bnr/spacemacs/issues/6587#issuecomment-232890021
;; make these keys behave like normal browser
(require 'xwidget)
(define-key xwidget-webkit-mode-map [mouse-4] 'xwidget-webkit-scroll-down)
(define-key xwidget-webkit-mode-map [mouse-5] 'xwidget-webkit-scroll-up)
(define-key xwidget-webkit-mode-map (kbd "<up>") 'xwidget-webkit-scroll-down)
(define-key xwidget-webkit-mode-map (kbd "<down>") 'xwidget-webkit-scroll-up)
(define-key xwidget-webkit-mode-map (kbd "M-w") 'xwidget-webkit-copy-selection-as-kill)
(define-key xwidget-webkit-mode-map (kbd "C-c") 'xwidget-webkit-copy-selection-as-kill)

;; 自动调整 xwidget-webkit 窗口大小（也可以手动按 a 来调整）。
(add-hook 'window-configuration-change-hook
	  (lambda ()
	    (when (equal major-mode 'xwidget-webkit-mode)
	      (xwidget-webkit-adjust-size-dispatch))))

;; make xwidget default browser
(setq browse-url-browser-function
      (lambda (url session)
	(other-window 1)
	(xwidget-webkit-browse-url url)))

;;在线搜索, 先选中 region 再执行搜索。
(use-package engine-mode
  :config
  (engine/set-keymap-prefix (kbd "C-c s"))
  (engine-mode t)
  ;;(setq engine/browser-function 'eww-browse-url)
  (setq engine/browser-function 'xwidget-webkit-browse-url)
  (defengine github "https://github.com/search?ref=simplesearch&q=%s" :keybinding "h")
  (defengine google "https://google.com/search?q=%s" :keybinding "g"))

;; Google 翻译
(use-package google-translate
  :config
  ;; C-n/p 切换翻译类型。
  (setq google-translate-translation-directions-alist
        '(("en" . "zh-CN") ("zh-CN" . "en")))
  (global-set-key (kbd "C-c d t") #'google-translate-smooth-translate))

;; 删除文件时, 将文件移动到回收站。
(use-package osx-trash
  :config
  (when (eq system-type 'darwin)
    (osx-trash-setup))
  (setq-default delete-by-moving-to-trash t))

;; 在 Finder 中打开当前文件。
(use-package reveal-in-osx-finder
  :commands (reveal-in-osx-finder))

;; 在帮助文档底部显示 lisp demo.
(use-package elisp-demos
  :config
  (advice-add 'describe-function-1 :after #'elisp-demos-advice-describe-function-1)
  (advice-add 'helpful-update :after #'elisp-demos-advice-helpful-update))

;; 相比 Emacs 内置 Help, 提供更多上下文信息。
(use-package helpful
  :config
  (global-set-key (kbd "C-h f") #'helpful-callable)
  (global-set-key (kbd "C-h v") #'helpful-variable)
  (global-set-key (kbd "C-h k") #'helpful-key)
  (global-set-key (kbd "C-c C-d") #'helpful-at-point)
  (global-set-key (kbd "C-h F") #'helpful-function)
  (global-set-key (kbd "C-h C") #'helpful-command))

(use-package pdf-tools
  ;; :ensure-system-package
  ;; ((pdfinfo . poppler)
  ;;  (automake . automake)
  ;;  (mutool . mupdf)
  ;;  ("/usr/local/opt/zlib" . zlib))
  :init
  ;; 使用 scaling 确保中文字体不模糊
  (setq pdf-view-use-scaling t)
  (setq pdf-view-use-imagemagick nil)
  (setq pdf-annot-activate-created-annotations t)
  (setq pdf-view-resize-factor 1.1)
  (setq-default pdf-view-display-size 'fit-page)
  (setq pdf-annot-activate-created-annotations t)
  :hook
  ((pdf-view-mode . pdf-view-themed-minor-mode)
   (pdf-view-mode . pdf-view-auto-slice-minor-mode)
   (pdf-view-mode . pdf-isearch-minor-mode))
  :config
  (define-key pdf-view-mode-map (kbd "C-s") 'isearch-forward)
  ;;(add-hook 'pdf-view-mode-hook (lambda() (linum-mode -1)))
  (setq pdf-info-epdfinfo-program "/opt/homebrew/bin/epdfinfo")
  (setenv "PKG_CONFIG_PATH" "/opt/homebrew/opt/zlib/lib/pkgconfig:/opt/homebrew/opt/pkgconfig:/opt/homebrew/lib/pkgconfig")
  (pdf-tools-install))

;; pdf 转为 png 时使用更高分辨率（默认 90）。
(setq doc-view-resolution 144)

;;(use-package org-noter)
