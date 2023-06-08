;; 关闭 package.el(后续使用 straight.el) 。
(setq package-enable-at-startup nil)

;; 配置 use-package 使用 straight.el 安装包。
(setq straight-use-package-by-default t)
;; 只 clone 最近一次 commit 历史, 减少磁盘空间占用。
(setq straight-vc-git-default-clone-depth 1)

;; 安装 straight.el。
(defvar bootstrap-version)
(let ((bootstrap-file (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(setq use-package-verbose t)
(setq use-package-always-demand t)
(setq use-package-compute-statistics t)
;; 安装 use-package。
(straight-use-package 'use-package)

(use-package exec-path-from-shell
  :custom
  ;; 去掉 -l 参数, 加快启动速度。
  (exec-path-from-shell-arguments '("-l")) 
  (exec-path-from-shell-check-startup-files nil)
  (exec-path-from-shell-variables '("PATH" "MANPATH" "GOPATH" "GOPROXY" "GOPRIVATE" "GOFLAGS" "GO111MODULE" "PYTHONPATH"))
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

;; 提升 IO 性能。
(setq process-adaptive-read-buffering nil)
;; 增加单次读取进程输出的数据量（缺省 4KB) 。
(setq read-process-output-max (* 1024 1024 10))

;; Garbage Collector Magic Hack
(use-package gcmh
  :init
  ;; 在 minibuffer 显示 GC 信息。
  ;;(setq garbage-collection-messages t)
  ;;(setq gcmh-verbose t)
  (setq gcmh-idle-delay 5)
  (setq gcmh-high-cons-threshold (* 100 1024 1024))
  (gcmh-mode 1)
  (gcmh-set-high-threshold))

;; EasyPG 加密。
(use-package epa
  :config
  ;; 缺省使用 email 地址加密。
  (setq-default epa-file-select-keys nil)
  (setq-default epa-file-encrypt-to user-mail-address)
  ;; 使用 minibuffer 输入 GPG 密码。
  (setq-default epa-pinentry-mode 'loopback)
  ;; 认证信息文件。
  (setq auth-sources '("~/.authinfo.gpg" "~/work/proxylist/hosts_auth"))
  ;; 认证不过期, 默认 7200。
  (setq auth-source-cache-expiry nil)
  ;;(setq auth-source-debug t)
  ;; 缓存对称加密密码。
  (setq epa-file-cache-passphrase-for-symmetric-encryption t)
  ;; gpg 文件。
  (require 'epa-file)
  (epa-file-enable))

;; 关闭容易误操作的按键。
(global-unset-key (kbd "s-w"))
(global-unset-key (kbd "C-z"))
(global-unset-key (kbd "<mouse-2>"))
(global-unset-key (kbd "s-k"))
(global-unset-key (kbd "s-o"))
(global-unset-key (kbd "s-t"))
(global-unset-key (kbd "s-p"))
(global-unset-key (kbd "s-n"))
(global-unset-key (kbd "s-,"))
(global-unset-key (kbd "s-."))
(global-unset-key (kbd "C-<wheel-down>"))
(global-unset-key (kbd "C-<wheel-up>"))

;; 在单独文件保存自定义配置，避免污染 ~/.emacs 文件。
(setq custom-file (expand-file-name "~/.emacs.d/custom.el"))
(add-hook 'after-init-hook (lambda () (when (file-exists-p custom-file) (load custom-file))))

(when (memq window-system '(mac ns x))
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (menu-bar-mode -1)
  (setq use-file-dialog nil)
  (setq use-dialog-box nil))

;; 向下翻另外的窗口。
(global-set-key (kbd "s-v") 'scroll-other-window)  
 ;; 向上翻另外的窗口。
(global-set-key (kbd "C-s-v") 'scroll-other-window-down)

;; 不显示 Title Bar（依赖编译时指定 --with-no-frame-refocus 参数。）
(add-to-list 'default-frame-alist '(undecorated-round . t))

;; 高亮当前行。
;;(setq global-hl-line-sticky-flag t)
;;(global-hl-line-mode t)

;; 指针闪动。
;;(blink-cursor-mode t)

;; 光标和字符宽度一致（如 TAB)
(setq x-stretch-cursor nil)

;; 不显示 window fringe, 显示多个 window 时更紧凑。
(set-fringe-style 0)

;; 增加行间距。
(setq-default line-spacing 0.05)

;; 30: 左右分屏, nil: 上下分屏。
(setq split-width-threshold 30)

;; 滚动一屏后显示 3 行上下文。
(setq next-screen-context-lines 3)

;; 像素平滑滚动。
(if (boundp 'pixel-scroll-precision-mode)
    (pixel-scroll-precision-mode t))

;; 加 t 参数让 togg-frame-XX 最后运行，这样最大化才生效。
;;(add-hook 'window-setup-hook 'toggle-frame-fullscreen t) 
(add-hook 'window-setup-hook 'toggle-frame-maximized t)

;; 不在新 frame 打开文件（如 Finder 的 "Open with Emacs") 。
(setq ns-pop-up-frames nil)

;; 复用当前 frame。
(setq display-buffer-reuse-frames t)

;; 手动刷行显示。
(global-set-key (kbd "<f5>") #'redraw-display)

;; 在 frame 底部显示窗口。
(setq display-buffer-alist
      `((,(rx bos (or
                   "*Apropos*"
                   "*Help*"
                   "*helpful"
                   "*info*"
                   "*Summary*"
                   "*vterm"
                   "*lsp-bridge"
                   "*Org"
                   "*Google Translate*"
                   "Shell Command Output") (0+ not-newline))
         (display-buffer-below-selected display-buffer-at-bottom)
         (inhibit-same-window . t)
         (window-height . 0.33))))

;; 透明背景。
(defun my/toggle-transparency ()
  (interactive)
  (set-frame-parameter (selected-frame) 'alpha '(90 . 90)) ;; 分别为 frame 获得焦点和失去焦点的不透明度。
  (add-to-list 'default-frame-alist '(alpha . (90 . 90))))

;; 高亮光标移动到的行。
(use-package pulsar
  :straight (pulsar :host github :repo "protesilaos/pulsar")
  :config
  (setq pulsar-pulse t)
  (setq pulsar-delay 0.25)
  (setq pulsar-iterations 15)
  (setq pulsar-face 'pulsar-magenta)
  (setq pulsar-highlight-face 'pulsar-yellow)
  (pulsar-global-mode 1)
  (add-hook 'next-error-hook #'pulsar-pulse-line-red)
  ;; integration with the `consult' package:
  (add-hook 'consult-after-jump-hook #'pulsar-recenter-top)
  (add-hook 'consult-after-jump-hook #'pulsar-reveal-entry)
  ;; integration with the built-in `imenu':
  (add-hook 'imenu-after-jump-hook #'pulsar-recenter-top)
  (add-hook 'imenu-after-jump-hook #'pulsar-reveal-entry))

;; 调整窗口大小。
(global-set-key (kbd "C-s-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "C-s-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "C-s-<down>") 'shrink-window)
(global-set-key (kbd "C-s-<up>") 'enlarge-window)

;; window 窗口选择。
(global-set-key (kbd "s-o") #'other-window)

;; 滚动显示。
(global-set-key (kbd "C-s-j") (lambda () (interactive) (scroll-up 2)))
(global-set-key (kbd "C-s-k") (lambda () (interactive) (scroll-down 2)))

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
  (setq dashboard-items '((recents . 15) (projects . 8) (agenda . 3))))

(use-package doom-modeline
  :hook (after-init . doom-modeline-mode)
  :custom
  ;; 不显示换行和编码。
  (doom-modeline-buffer-encoding nil)
  ;; 显示语言版本。
  (doom-modeline-env-version t)
  ;; 不显示 go 版本。
  (doom-modeline-env-enable-go nil)
  (doom-modeline-buffer-file-name-style 'truncate-nil) ;; relative-from-project
  (doom-modeline-vcs-max-length 30)
  (doom-modeline-github nil)
  (doom-modeline-height 1)
  (doom-modeline-time-icon nil)
  :config
  ;; 电池和日期。
  (display-battery-mode 1)
  (column-number-mode t)
  (size-indication-mode t)
  (display-time-mode t)
  (setq display-time-24hr-format t)
  ;; system load 大于 10 时才在 modeline 显示；
  (setq display-time-default-load-average nil)
  (setq display-time-load-average-threshold 10)
  (setq display-time-format "%m/%d[%w]%H:%M ")
  (setq display-time-day-and-date t)
  (setq indicate-buffer-boundaries (quote left)))

;; 缺省字体；
(setq +font-family "Iosevka Comfy")
;; modeline 字体，未设置的情况下使用 variable-pitch 字体。
(setq +modeline-font-family "Iosevka Comfy")
;; fixed-pitch 字体；
(setq +fixed-pitch-family "Iosevka Comfy")
;; variable-pitch 字体；
(setq +variable-pitch-family "LXGW WenKai Screen")
;; 中文字体；
(setq +font-unicode-family "LXGW WenKai Screen")
;; 中文字体和英文字体按照 1:1 缩放，在偶数字号的情况下可以实现等宽等高。
(setq face-font-rescale-alist '(("LXGW WenKai Screen" . 1))) ;; 1:1 缩放。
(setq +font-size 14) ;; 偶数字号。


;; 设置缺省字体。
(defun +load-base-font ()
  ;; 只为缺省字体设置 size, 其它字体都通过 :height 动态伸缩。
  (let* ((font-spec (format "%s-%d" +font-family +font-size)))
    (set-frame-parameter nil 'font font-spec)
    (add-to-list 'default-frame-alist `(font . ,font-spec))))

;; 设置各特定 face 的字体。
(defun +load-face-font (&optional frame)
  (let ((font-spec (format "%s" +font-family))
	(modeline-font-spec (format "%s" +modeline-font-family))
	(variable-pitch-font-spec (format "%s" +variable-pitch-family))
	(fixed-pitch-font-spec (format "%s" +fixed-pitch-family)))
    (set-face-attribute 'variable-pitch frame :font variable-pitch-font-spec)
    (set-face-attribute 'fixed-pitch frame :font fixed-pitch-font-spec)
    (set-face-attribute 'fixed-pitch-serif frame :font fixed-pitch-font-spec)
    (set-face-attribute 'tab-bar frame :font font-spec)
    (set-face-attribute 'mode-line frame :font modeline-font-spec)
    (set-face-attribute 'mode-line-inactive frame :font modeline-font-spec)))

;; 设置中文字体。
(defun +load-ext-font ()
  (when window-system
    (let ((font (frame-parameter nil 'font))
	  (font-spec (font-spec :family +font-unicode-family)))
      (dolist (charset '(kana han hangul cjk-misc bopomofo))
	(set-fontset-font font charset font-spec)))))

;; 设置 Emoji 和 Symbol 字体。
(defun +load-emoji-font ()
  (when window-system
    (setq use-default-font-for-symbols nil)
    (set-fontset-font t 'emoji (font-spec :family "Apple Color Emoji")) ;; Noto Color Emoji
    (set-fontset-font t 'symbol (font-spec :family "Apple Symbols")))) ;; Symbola

(add-hook 'after-make-frame-functions 
	  ( lambda (f) 
	    (+load-face-font)
	    (+load-ext-font)
	    (+load-emoji-font)))

;; 加载字体。
(defun +load-font ()
  (+load-base-font)
  (+load-face-font)
  (+load-ext-font)
  (+load-emoji-font))

(+load-font)

;; all-the-icons 只能在 GUI 模式下使用。
(when (display-graphic-p)
  (use-package all-the-icons :demand))

(use-package ef-themes
  :straight (ef-themes :host github :repo "protesilaos/ef-themes")
  :config
  ;; Disable all other themes to avoid awkward blending:
  (mapc #'disable-theme custom-enabled-themes)
  ;; 关闭 variable-pitch 模式，否则 modeline 可能溢出。
  (setq ef-themes-variable-pitch-ui t)
  ;; strictly spacing-sensitive constructs inherit from fixed-pitch (a monospaced font family) faces
  ;; such as for Org tables, inline code, code blocks, and the like, are rendered in a monospaced font
  ;; at all times
  (setq ef-themes-mixed-fonts t)
  ;; 调整 org-mode 等 header 的显示比例。
  (setq ef-themes-headings
        '(
          ;; level 0 是文档 title，1-8 是普通的文档 headling。
          (0 . (variable-pitch semibold 1.6))
          (1 . (variable-pitch light 1.5))
          (2 . (variable-pitch regular 1.4))
          (3 . (variable-pitch regular 1.3))
          (4 . (variable-pitch regular 1.2))
          (5 . (variable-pitch 1.1)) ; absence of weight means `bold'
          (6 . (variable-pitch 1.1))
          (7 . (variable-pitch 1.1))
          (agenda-date . (semilight 1.5))
          (agenda-structure . (variable-pitch light 1.9))
          ;; default style for all unspecified levels
          (t . (variable-pitch 1.1))))
  (setq ef-themes-region '(intense no-extend neutral)))

(defun my/load-light-theme () (interactive) (load-theme 'ef-spring t)) ;; ef-day doom-one-light
(defun my/load-dark-theme () (interactive) (load-theme 'ef-night t)) ;; ef-night doom-palenight
(add-hook 'ns-system-appearance-change-functions
          (lambda (appearance)
            (pcase appearance
              ('light (my/load-light-theme))
              ('dark (my/load-dark-theme)))))

(use-package tab-bar
  :straight (:type built-in)
  :custom
  (tab-bar-close-button-show nil)
  (tab-bar-new-button-show nil)
  (tab-bar-history-limit 20)
  (tab-bar-new-tab-choice "*dashboard*")
  (tab-bar-show 1)
  (tab-bar-tab-hints t) ;; 显示 tab 序号。
  (tab-bar-select-tab-modifiers "super") ;; 使用 super + N 来切换 tab。
  :config
  ;; 去掉最左侧的 < 和 >
  (setq tab-bar-format '(tab-bar-format-tabs-groups
                         tab-bar-separator
                         tab-bar-format-add-tab ))

  ;; 开启 tar-bar history mode 后才支持 history-back/forward 命令。
  (tab-bar-history-mode t)
  (global-set-key (kbd "s-f") 'tab-bar-history-forward)
  (global-set-key (kbd "s-b") 'tab-bar-history-back)
  ;; 快速 tab 操作。
  (global-set-key (kbd "s-t") 'tab-bar-new-tab)
  (global-set-key (kbd "s-0") 'tab-bar-close-tab)
  (global-set-key (kbd "s-1") 'tab-bar-select-tab)
  (global-set-key (kbd "s-2") 'tab-bar-select-tab)
  (global-set-key (kbd "s-3") 'tab-bar-select-tab)
  (global-set-key (kbd "s-4") 'tab-bar-select-tab)
  (global-set-key (kbd "s-5") 'tab-bar-select-tab)
  (global-set-key (kbd "s-6") 'tab-bar-select-tab)
  (global-set-key (kbd "s-7") 'tab-bar-select-tab)
  (global-set-key (kbd "s-8") 'tab-bar-select-tab)
  (global-set-key (kbd "s-9") 'tab-bar-select-tab))

(use-package sort-tab
  :demand
  :straight (:repo "manateelazycat/sort-tab" :host github)
  ;; emacs 启动后再启用 sort-tab 防止显示异常。
  :hook (after-init . sort-tab-mode)
  :config
  ;;(sort-tab-mode 1)
  (setq sort-tab-show-index-number t)
  (setq sort-tab-height 40)
  (global-set-key (kbd "s-n") 'sort-tab-select-next-tab)
  (global-set-key (kbd "s-p") 'sort-tab-select-prev-tab)
  (global-set-key (kbd "s-w") 'sort-tab-close-current-tab)
  ;; 设置 tab 颜色，M-x list-colors-display。
  (set-face-foreground 'sort-tab-current-tab-face "peru")
  ;; 不显示背景颜色。
  (set-face-background 'sort-tab-current-tab-face nil))

(use-package vertico
  :straight (:repo "minad/vertico" :files ("*" "extensions/*.el" (:exclude ".git")))
  :hook
  ;; 在输入时清理文件路径。
  (rfn-eshadow-update-overlay . vertico-directory-tidy)
  :config
  ;; 显示的侯选者数量。
  (setq vertico-count 20)
  (setq vertico-cycle nil)
  (vertico-mode 1)
  ;; 文件路径操作。
  (define-key vertico-map (kbd "<backspace>") #'vertico-directory-delete-char)
  (define-key vertico-map (kbd "RET") #'vertico-directory-enter))

(use-package emacs
  :init
  ;; 在 minibuffer 中不显示光标。
  (setq minibuffer-prompt-properties '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)
  ;; M-x 时只显示当前 mode 支持的命令的命令。
  (setq read-extended-command-predicate #'command-completion-default-include-p)
  ;; 开启 minibuffer 递归编辑。
  (setq enable-recursive-minibuffers t))

(use-package orderless
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

  ;; 在 orderless-affix-dispatch 的基础上添加上面支持文件名扩展和 正则表达式$ 的 dispatchers 。
  (setq orderless-style-dispatchers (list #'+orderless-consult-dispatch
                                          #'orderless-affix-dispatch))

  ;; 自定义名为 +orderless-with-initialism 的 orderless 风格。
  (orderless-define-completion-style +orderless-with-initialism
    (orderless-matching-styles '(orderless-initialism orderless-literal orderless-regexp)))
  
  ;; 使用 orderless 和 emacs 原生的 basic 补全风格， 但 orderless 的优先级更高。
  (setq completion-styles '(orderless basic))
  (setq completion-category-defaults nil)
  ;; 进一步设置各 category 使用的补全风格。
  (setq completion-category-overrides
        '(;; buffer name 补全
          (buffer (styles +orderless-with-initialism)) 
          ;; file path&name 补全, partial-completion 提供了 wildcard 支持。
          (file (styles basic partial-completion)) 
          ;; M-x Command 补全
          (command (styles +orderless-with-initialism)) 
          ;; variable 补全
          (variable (styles +orderless-with-initialism))
          ;; symbol 补全
          (symbol (styles +orderless-with-initialism))
          )) 
  ;; 使用 SPACE 来分割过滤字符串, SPACE 可以用 \ 转义。
  (setq orderless-component-separator #'orderless-escapable-split-on-space))

(use-package consult
  :straight (consult :host github :repo "minad/consult")
  :hook
  (completion-list-mode . consult-preview-at-point-mode)
  :init
  ;; 如果搜索字符少于 3，可以添加后缀#开始搜索，如 #gr#。
  (setq consult-async-min-input 3)
  ;; 从头开始搜索（而非前位置）。
  (setq consult-line-start-from-top t)
  ;; 预览寄存器。
  (setq register-preview-function #'consult-register-format)
  (advice-add #'register-preview :override #'consult-register-window)
  ;; 使用 consult 来预览 xref 的引用定义和跳转。
  (setq xref-show-xrefs-function #'consult-xref)
  (setq xref-show-definitions-function #'consult-xref)
  :config
  ;; 按 C-l 激活预览，否则 Buffer 列表中有大文件或远程文件时会卡住。
  (setq consult-preview-key "C-l")
  ;; Use minibuffer completion as the UI for completion-at-point. 也可以使用 Corfu 或 Company 等直接在 buffer
  ;; 中 popup 显示补全。
  (setq completion-in-region-function #'consult-completion-in-region)
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
     "[0-9]+.gpg")))

;; consult line 时自动展开 org 内容。
;; https://github.com/minad/consult/issues/563#issuecomment-1186612641
(defun my/org-show-entry (fn &rest args)
  (interactive)
  (when-let ((pos (apply fn args)))
    (when (derived-mode-p 'org-mode)
      (org-fold-show-entry))))
(advice-add 'consult-line :around #'my/org-show-entry)

;;; consult
;; C-c 绑定 (mode-specific-map)
(global-set-key (kbd "C-c M-x") #'consult-mode-command)
(global-set-key (kbd "C-c i") #'consult-info)
(global-set-key (kbd "C-c m") #'consult-man)
;; C-x 绑定 (ctl-x-map)
;; 使用 savehist 持久化保存的 minibuffer 历史。
(global-set-key (kbd "C-M-;") #'consult-complex-command) 
(global-set-key (kbd "C-x b") #'consult-buffer)
(global-set-key (kbd "C-x 4 b") #'consult-buffer-other-window)
(global-set-key (kbd "C-x 5 b") #'consult-buffer-other-frame)
(global-set-key (kbd "C-x r b") #'consult-bookmark)
(global-set-key (kbd "C-x p b") #'consult-project-buffer)
;; 寄存器绑定。
(global-set-key (kbd "C-'") #'consult-register-store)
(global-set-key (kbd "C-M-'") #'consult-register)
;; 其它自定义绑定。
(global-set-key (kbd "M-y") #'consult-yank-pop)
(global-set-key (kbd "M-Y") #'consult-yank-from-kill-ring)
;; M-g 绑定 (goto-map)
(global-set-key (kbd "M-g e") #'consult-compile-error)
;;(global-set-key (kbd "M-g f") #'consult-flycheck)
(global-set-key (kbd "M-g g") #'consult-goto-line)
(global-set-key (kbd "M-g o") #'consult-outline)
;; consult-buffer 默认已包含 recent file.
;;(global-set-key (kbd "M-g r") #'consult-recent-file)
(global-set-key (kbd "M-g m") #'consult-mark)
(global-set-key (kbd "M-g k") #'consult-global-mark)
(global-set-key (kbd "M-g i") #'consult-imenu)
;;Jump to imenu item in project buffers, with the same major mode as the current buffer. 
(global-set-key (kbd "M-g I") #'consult-imenu-multi)
;; M-s 绑定 (search-map)使用 # 分割的两段式匹配, 第一段为正则表达式, 例如: #regexps#filter-string, 输入的必须
;; 时 Emacs 正则表达式, consult 再转换为对应 grep/ripgrep 正则表达式。多个正则表达式使用空格分割，必须都需要匹
;; 配。如果要批评空格，则需要使用转移字符。filter-string 是对正则批评的内容进行过滤，支持 orderless 风格的匹配
;; 字符串列表。例如: #\(consult\|embark\): Search for “consult” or “embark” using grep. Note the usage of
;; Emacs-style regular expressions.
(global-set-key (kbd "M-s g") #'consult-grep)
(global-set-key (kbd "M-s G") #'consult-git-grep)
(global-set-key (kbd "M-s r") #'consult-ripgrep)
;; 对文件名使用正则匹配。
(global-set-key (kbd "M-s d") #'consult-find)
(global-set-key (kbd "M-s D") #'consult-locate)
(global-set-key (kbd "M-s l") #'consult-line)
(global-set-key (kbd "M-s M-l") #'consult-line)
;; Search dynamically across multiple buffers. By default search across project buffers. If invoked with a
;; prefix argument search across all buffers.
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

(use-package embark
  :straight (embark :files ("*.el"))
  :init
  ;; 使用 C-h 来显示 key preifx 绑定。
  (setq prefix-help-command #'embark-prefix-help-command)
  ;; 执行完 action 后不关闭 window 。
  ;;(setq embark-quit-after-action nil)
  :config
  (setq embark-prompter 'embark-keymap-prompter)
  ;; 隐藏 Embark live/completions buffers 的 modeline.
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none))))
  (global-set-key (kbd "C-;") #'embark-act)
  ;; 描述当前 buffer 可以使用的快捷键。
  (define-key global-map [remap describe-bindings] #'embark-bindings))

;; embark-consult 支持 embark 和 consult 集成，如使用 wgrep 编辑 consult grep/line 的 export 的结果。
(use-package embark-consult
  :after (embark consult)
  :hook  (embark-collect-mode . consult-preview-at-point-mode))

;; 编辑 grep buffers, 可以和 consult-grep 和 embark-export 联合使用。
(use-package wgrep)

(use-package marginalia
  :init
  ;; 显示绝对时间。
  (setq marginalia-max-relative-age 0)
  (marginalia-mode)
  :config
  ;; 文件不添加大小，修改时间等注释，防止 tramp 时卡住。
  (setq marginalia-annotator-registry (assq-delete-all 'file marginalia-annotator-registry))
  (setq marginalia-annotator-registry (assq-delete-all 'project-file marginalia-annotator-registry)))

(use-package yasnippet
  :init
  (defvar snippet-directory "~/.emacs.d/snippets")
  :hook
  ((prog-mode org-mode  vterm-mode) . yas-minor-mode)
  :config
  (add-to-list 'yas-snippet-dirs snippet-directory)
  ;; 保留 snippet 的缩进。
  (setq yas-indent-line 'fixed)
  (yas-global-mode 1))

(use-package consult-yasnippet
  :after(consult yasnippet)
  :config
  (define-key yas-minor-mode-map (kbd "C-c y") #'consult-yasnippet))

;; 避免报错：Symbol’s function definition is void: yasnippet-snippets--fixed-indent
(use-package yasnippet-snippets :after(yasnippet))

(use-package dired
  :straight (:type built-in)
  :config
  ;; re-use dired buffer, available in Emacs 28, @see https://debbugs.gnu.org/cgi/bugreport.cgi?bug=20598
  (setq dired-kill-when-opening-new-dired-buffer t)
  ;; if another Dired buffer is visible in another window, use that directory as target for Rename/Copy
  (setq dired-dwim-target t)
  ;; @see https://emacs.stackexchange.com/questions/5649/sort-file-names-numbered-in-dired/5650#5650
  ;; 下面的参数只对安装了 coreutils (brew install coreutils) 的包有效，否则会报错。
  (setq dired-listing-switches "-laGh1v --group-directories-first")
  (put 'dired-find-alternate-file 'disabled nil))

;; dired 显示高亮增强。
(use-package diredfl :config (diredfl-global-mode))

(use-package grep
  :config
  (setq grep-highlight-matches t)
  (setq grep-find-ignored-directories
	(append
	 (list
          ".git"
          ".hg"
          ".idea"
          ".project"
          ".settings"
          "bootstrap*"
          "pyenv"
          "target"
          ".cache"
          "vendor"
          "node_modules"
        )
	 grep-find-ignored-directories))
  (setq grep-find-ignored-files
	(append
	 (list
          "*.blob"
          "*.gz"
          "*.jar"
          "*.xd"
          "TAGS"
          "projectile.cache"
          "GPATH"
          "GRTAGS"
          "GTAGS"
          "TAGS"
          ".project"
          ".DS_Store"
          )
	 grep-find-ignored-files)))

(global-set-key "\C-cn" 'find-dired)
(global-set-key "\C-cN" 'grep-find)

(setq isearch-allow-scroll 'unlimited)
;; 显示当前和总的数量。
(setq isearch-lazy-count t)
(setq isearch-lazy-highlight t)

;; browser-url 使用 Firefox 浏览器。
(setq browse-url-firefox-program "/Applications/Firefox.app/Contents/MacOS/firefox")
(setq browse-url-browser-function 'browse-url-firefox) ;; browse-url-default-macosx-browser, xwidget-webkit-browse-url
(setq xwidget-webkit-cookie-file "~/.emacs.d/cookie.txt")
(setq xwidget-webkit-buffer-name-format "*webkit: %T")

(use-package engine-mode
  :config
  (engine/set-keymap-prefix (kbd "C-c s"))
  (engine-mode t)
  ;;(setq engine/browser-function 'eww-browse-url)
  (defengine github "https://github.com/search?ref=simplesearch&q=%s" :keybinding "h")
  (defengine google "http://www.google.com/search?ie=utf-8&oe=utf-8&q=%s" :keybinding "g"))

(use-package rime
  ;;:ensure-system-package
  ;;("/Applications/SwitchKey.app" . "brew install --cask switchkey")
  :custom
  (rime-user-data-dir "~/Library/Rime/")
  (rime-librime-root "~/.emacs.d/librime/dist")
  (rime-emacs-module-header-root "/usr/local/opt/emacs-plus@29/include")
  :hook
  (emacs-startup . (lambda () (setq default-input-method "rime")))
  :bind
  ( :map rime-active-mode-map
    ;; 在已经激活 Rime 候选菜单时，强制在中英文之间切换，直到按回车。
    ("M-j" . 'rime-inline-ascii)
    :map rime-mode-map
    ;; 强制切换到中文模式
    ("M-j" . 'rime-force-enable)
    ;; 下面这些快捷键需要发送给 rime 来处理, 需要与 default.custom.yaml 文件中的 key_binder/bindings 配置相匹配。
    ;; 中英文切换
    ("C-." . 'rime-send-keybinding)
    ;; 输入法菜单
    ("C-+" . 'rime-send-keybinding)
    ;; 中英文标点切换
    ("C-," . 'rime-send-keybinding)
    ;; 全半角切换
    ;; ("C-," . 'rime-send-keybinding)
    )
  :config
  ;; 在 modline 高亮输入法图标, 可用来快速分辨分中英文输入状态。
  (setq mode-line-mule-info '((:eval (rime-lighter))))
  ;; 将如下快捷键发送给 rime，同时需要在 rime 的 key_binder/bindings 的部分配置才会生效。
  (add-to-list 'rime-translate-keybindings "C-h") ;; 删除拼音字符
  (add-to-list 'rime-translate-keybindings "C-d")
  (add-to-list 'rime-translate-keybindings "C-k") 
  (add-to-list 'rime-translate-keybindings "C-a") ;; 跳转到第一个拼音字符
  (add-to-list 'rime-translate-keybindings "C-e") ;; 跳转到最后一个拼音字符
  ;; support shift-l, shift-r, control-l, control-r, 只有当使用系统 RIME 输入法时才有效。
  (setq rime-inline-ascii-trigger 'shift-l)
  ;; 临时英文模式。
  (setq rime-disable-predicates
        '(rime-predicate-ace-window-p
          rime-predicate-hydra-p
          rime-predicate-current-uppercase-letter-p
          ;;rime-predicate-after-alphabet-char-p
          ;;rime-predicate-prog-in-code-p
          ))
  (setq rime-show-candidate 'posframe)
  (setq default-input-method "rime")

  (setq rime-posframe-properties
        (list :background-color "#333333"
              :foreground-color "#dcdccc"
              :internal-border-width 2))

  ;; 部分 major-mode 关闭 RIME 输入法。
  (defadvice switch-to-buffer (after activate-input-method activate)
    (if (or (string-match "vterm-mode" (symbol-name major-mode))
            (string-match "dired-mode" (symbol-name major-mode))
            (string-match "image-mode" (symbol-name major-mode))
            (string-match "minibuffer-mode" (symbol-name major-mode)))
        (activate-input-method nil)
      (activate-input-method "rime"))))

(use-package org
  :straight (:type built-in)
  :ensure auctex
  :config
  (setq org-ellipsis "..." ;; " ⭍"
        ;; 使用 UTF-8 显示 LaTeX 或 \xxx 特殊字符， M-x org-entities-help 查看所有特殊字符。
        org-pretty-entities t
        org-highlight-latex-and-related '(latex)
        ;; 只显示而不处理和解释 latex 标记，例如 \xxx 或 \being{xxx}, 避免 export pdf 时出错。
        org-export-with-latex 'verbatim
        ;; 隐藏标记字符。
        org-hide-emphasis-markers t

        ;; 去掉 * 和 /, 使它们不再具有强调含义。
        ;; org-emphasis-alist
        ;; '(("_" underline)
        ;;   ("=" org-verbatim verbatim)
        ;;   ("~" org-code verbatim)
        ;;   ("+" (:strike-through t)))

        ;; 隐藏 block
        org-hide-block-startup t
        org-hidden-keywords '(title)
        org-cycle-separator-lines 2
        org-cycle-level-faces t
        org-n-level-faces 4
        ;; TODO 状态更新记录到 LOGBOOK Drawer 中。
        org-log-into-drawer t
        ;; TODO 状态更新时记录 note.
        org-log-done 'note ;; note, time
        ;; 默认显示 inline image.
        org-startup-with-inline-images t
        ;; 先从 #+ATTR.* 获取宽度，如果没有设置则默认为 300 。
        org-image-actual-width '(300)
        ;; cycle headline 时显示 image.
        org-cycle-inline-images-display t
        org-export-with-broken-links t
        ;; 文件链接使用相对路径, 解决 hugo 等 image 引用的问题。
        org-link-file-path-type 'relative
        org-startup-folded 'content
        ;; 使用 R_{s} 形式的下标（默认是 R_s, 容易与正常内容混淆) 。
        org-use-sub-superscripts nil
        ;; headerline 默认加序号。
        org-startup-numerated t
        org-startup-indented t
        ;; export 时不处理 super/subscripting, 等效于 #+OPTIONS: ^:nil 。
        org-export-with-sub-superscripts nil
        ;; heaerline 不显示 *。
        org-hide-leading-stars t
        ;; 缩进 2 个字符。
        org-indent-indentation-per-level 2
        ;; 内容缩进与对应 headerline 一致。
        org-adapt-indentation t
        org-list-indent-offset 2
        org-html-validation-link nil
        ;; org-timer 到期时发送声音提示。
        org-clock-sound t)
  ;;(setq org-fold-core-style 'overlays)
  ;; 不自动对齐 tag
  (setq org-tags-column 0)
  (setq  org-auto-align-tags nil)
  ;; 显示不可见的编辑。
  (setq org-catch-invisible-edits 'show-and-error)
  (setq org-special-ctrl-a/e t)
  (setq org-fold-catch-invisible-edits t)
  (setq org-insert-heading-respect-content t)
  ;; 支持 ID property 作为 internal link target(默认是 CUSTOM_ID property)
  (setq org-id-link-to-org-use-id t)
  ;; 光标位于 section 中间时不 split line.
  (setq org-M-RET-may-split-line nil)
  (setq org-todo-keywords '((sequence "TODO(t!)" "DOING(d@)" "|" "DONE(D)")
                            (sequence "BLOCKED(b@)" "|" "CANCELLED(c@)")))
  (add-hook 'org-mode-hook 'turn-on-auto-fill)
  (add-hook 'org-mode-hook (lambda () (display-line-numbers-mode 0))))

;; 关闭与 pyim 冲突的 C-, 快捷键。
(define-key org-mode-map (kbd "C-,") nil)
(define-key org-mode-map (kbd "C-'") nil)
;; 关闭容易误碰的按键。
;; (define-key org-mode-map (kbd "C-c C-x a") nil)
;; (define-key org-mode-map (kbd "C-c C-x A") nil)
;; (define-key org-mode-map (kbd "C-c C-x C-s") nil)
;; 全局快捷键。
(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)
(global-set-key (kbd "C-c b") #'org-switchb)

;; C-u C-c l 获得文件链接时包含行号。
(defun my-link-to-line-number ()
  (number-to-string (org-current-line)))
(add-hook 'org-create-file-search-functions 'my-link-to-line-number)

;; 自动创建和更新目录。
(use-package org-make-toc
  :disabled
  :config
  (add-hook 'org-mode-hook #'org-make-toc-mode))

;; 关闭频繁弹出的 org-element-cache 警告 buffer 。
;;(setq warning-suppress-types (append warning-suppress-types '((org-element-cache))))
(setq org-element-use-cache nil)

;; 从各种 Mac 应用（如 finder/浏览器）获取 org-mode 链接。
(use-package org-mac-link
  :commands (org-mac-grab-link))

;; 编辑时显示隐藏的标记。
(use-package org-appear
  :config
  (add-hook 'org-mode-hook 'org-appear-mode)
  ;; 删除 * 和 / 类型的标记。
  ;; (setq org-appear-elements '(underline strike-through verbatim code))
  )

;; Org-modern replaces Org-superstar.
(use-package org-modern
  :after (org)
  :demand
  :straight (:host github :repo "minad/org-modern")
  :config
  (with-eval-after-load 'org (global-org-modern-mode)))

;; 使用 font-lock 来隐藏中文前后的空格。
;; https://emacs-china.org/t/org-mode/22313
(font-lock-add-keywords 'org-mode
                        '(("\\cc\\( \\)[/+*_=~][^a-zA-Z0-9/+*_=~\n]+?[/+*_=~]\\( \\)?\\cc?"
                           (1 (prog1 () (compose-region (match-beginning 1) (match-end 1) ""))))
                          ("\\cc?\\( \\)?[/+*_=~][^a-zA-Z0-9/+*_=~\n]+?[/+*_=~]\\( \\)\\cc"
                           (2 (prog1 () (compose-region (match-beginning 2) (match-end 2) "")))))
                        'append)
;; 导出时删除空格。
(with-eval-after-load 'ox
  (defun eli-strip-ws-maybe (text _backend _info)
    (let* ((text (replace-regexp-in-string
                  "\\(\\cc\\) *\n *\\(\\cc\\)"
                  "\\1\\2" text));; remove whitespace from line break
           ;; remove whitespace from `org-emphasis-alist'
           (text (replace-regexp-in-string "\\(\\cc\\) \\(.*?\\) \\(\\cc\\)"
                                           "\\1\\2\\3" text))
           ;; restore whitespace between English words and Chinese words
           (text (replace-regexp-in-string "\\(\\cc\\)\\(\\(?:<[^>]+>\\)?[a-z0-9A-Z-]+\\(?:<[^>]+>\\)?\\)\\(\\cc\\)"
                                           "\\1 \\2 \\3" text)))
      text))
  (add-to-list 'org-export-filter-paragraph-functions #'eli-strip-ws-maybe))

(defun my/org-mode-visual-fill (fill width)
  (setq-default
   ;; 自动换行的字符数。
   fill-column fill
   ;; window 可视化行宽度，值应该比 fill-column 大，否则超出的字符被隐藏。
   visual-fill-column-width width
   visual-fill-column-fringes-outside-margins nil
   ;; 使用 setq-default 来设置居中, 否则可能不生效。
   visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :after (org)
  :hook
  (org-mode . (lambda () (my/org-mode-visual-fill 110 130)))
  :config
  ;; 文字缩放时自动调整 visual-fill-column-width 。
  (advice-add 'text-scale-adjust :after #'visual-fill-column-adjust))

(use-package org-download
  :config
  (setq-default org-download-image-dir "./images/")
  (setq org-download-method 'directory
        org-download-display-inline-images 'posframe
        org-download-screenshot-method "pngpaste %s"
        org-download-image-attr-list '("#+ATTR_HTML: :width 400 :align center"))
  (add-hook 'dired-mode-hook 'org-download-enable)
  (org-download-enable)
  (global-set-key (kbd "<f6>") #'org-download-screenshot))

;; eval 前需要确认。
(setq org-confirm-babel-evaluate t)
;; 关闭 C-c C-c 触发 eval code.
;;(setq org-babel-no-eval-on-ctrl-c-ctrl-c nil)
(setq org-src-fontify-natively t)
;; 使用各语言的 Major Mode 来编辑 src block。
(setq org-src-tab-acts-natively t)
;; 为 #+begin_quote 和  #+begin_verse 添加特殊 face 。
(setq org-fontify-quote-and-verse-blocks t)
;; 不自动缩进。
(setq org-src-preserve-indentation t)
(setq org-edit-src-content-indentation 0)

;; 在当前窗口编辑 SRC Block.
;; 2023.04.05 设置为 current-window 后会导致 src window 不退出。
;;(setq org-src-window-setup 'current-window)

;; export 输出类型。
;;(setq org-export-backends '(go md gfm html latex man hugo))

;; yaml 从外部的 yaml-mode 切换到内置的 yaml-ts-mode，告诉 babel 使用该内置 mode，
;; 否则编辑 yaml src block 时提示找不到 yaml-mode。
(add-to-list 'org-src-lang-modes '("yaml" . yaml-ts))
(add-to-list 'org-src-lang-modes '("cue" . cue))

(require 'org)
;; org bable 完整支持的语言列表（ob- 开头的文件）：https://git.savannah.gnu.org/cgit/emacs/org-mode.git/tree/lisp
;; 对于官方不支持的语言，可以通过 use-pacakge 来安装。
(use-package ob-go) ;; golang 
(use-package ox-reveal) ;; reveal.js
(use-package ox-gfm) ;; github flavor markdown
;; 启用的 org babel 的语言列表。
(org-babel-do-load-languages
 'org-babel-load-languages
 '((shell . t)
   (js . t)
   (makefile . t)
   (go . t)
   (emacs-lisp . t)
   (python . t)
   (sed . t)
   (awk . t)
   (plantuml . t)
   (dot . t)
   (css . t)))

(use-package org-contrib
  :straight (org-contrib :repo "https://git.sr.ht/~bzg/org-contrib"))

;; engrave-faces 相比 minted 渲染速度更快。
(use-package engrave-faces
  :straight (:repo "tecosaur/engrave-faces")
  :after ox-latex
  :config
  (require 'engrave-faces-latex)
  ;; 使用默认 options, 否则生成 PDF 会报错。
  ;; (setq org-latex-engraved-options
  ;;       '(("commandchars" . "\\\\\\{\\}")
  ;;         ("highlightcolor" . "white!95!black!80!blue")
  ;;         ("breaklines" . "true")
  ;;         ("breaksymbol" . "\\color{white!60!black}\\tiny\\ensuremath{\\hookrightarrow}")
  ;;         ("frame" . "lines")
  ;;         ("linenos" "true")
  ;;         ("breaklines" "true")
  ;;         ("numbersep" "2mm")
  ;;         ("xleftmargin" "0.25in")
  ;;         ))
  (setq org-latex-src-block-backend 'engraved))

(require 'ox-latex)
(with-eval-after-load 'ox-latex
  ;; latex image 的默认宽度, 可以通过 #+ATTR_LATEX :width xx 配置。
  (setq org-latex-image-default-width "0.7\\linewidth")
  ;; 使用 booktabs style 来显示表格，例如支持隔行颜色, 这样 #+ATTR_LATEX: 中不需要添加 :booktabs t。
  (setq org-latex-tables-booktabs t)
  ;; 保存 LaTeX 日志文件。
  ;;(setq org-latex-remove-logfiles nil)  
  ;; 目录页前后分页。
  (setq org-latex-toc-command "\\clearpage \\tableofcontents \\clearpage")
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
(use-package htmlize
  :straight (htmlize :host github :repo "hniksic/emacs-htmlize"))

(use-package org-tree-slide
  :after (org)
  :commands org-tree-slide-mode
  :hook
  ((org-tree-slide-play . (lambda ()
                            (blink-cursor-mode +1)
                            (setq-default x-stretch-cursor -1)
                            (redraw-display)
                            (org-display-inline-images)
                            (text-scale-increase 1)
                            (read-only-mode 1)))
   (org-tree-slide-stop . (lambda ()
                            (blink-cursor-mode +1)
                            (setq-default x-stretch-cursor t)
                            (text-scale-increase 0)
                            (read-only-mode -1))))
  :config
  (setq org-tree-slide-header nil)
  (setq org-tree-slide-heading-emphasis nil)
  (setq org-tree-slide-slide-in-effect t)
  (setq org-tree-slide-content-margin-top 0)
  (setq org-tree-slide-activate-message " ")
  (setq org-tree-slide-deactivate-message " ")
  (setq org-tree-slide-modeline-display nil)
  (setq org-tree-slide-breadcrumbs " 👉 ")
  ;; 隐藏 #+KEYWORD 行内容。
  (defun +org-present-hide-blocks-h ()
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward "^[[:space:]]*\\(#\\+\\)\\(\\(?:BEGIN\\|END\\|begin\\|end\\|ATTR\\|DOWNLOADED\\)[^[:space:]]+\\).*" nil t)
        (org-flag-region (match-beginning 0) (match-end 0) org-tree-slide-mode t))))
  (add-hook 'org-tree-slide-play-hook #'+org-present-hide-blocks-h)
  (define-key org-mode-map (kbd "<f8>") #'org-tree-slide-mode)
  (define-key org-tree-slide-mode-map (kbd "<f9>") #'org-tree-slide-content)
  (define-key org-tree-slide-mode-map (kbd "<left>") #'org-tree-slide-move-previous-tree)
  (define-key org-tree-slide-mode-map (kbd "<right>") #'org-tree-slide-move-next-tree))

;; 设置缺省 prefix key, 必须在加载 org-journal 前设置。
(setq org-journal-prefix-key "C-c j")

(use-package org-journal
  :commands org-journal-new-entry
  :init
  (defun org-journal-save-entry-and-exit()
    (interactive)
    (save-buffer)
    (kill-buffer-and-window))
  :config
  (define-key org-journal-mode-map (kbd "C-c C-e") #'org-journal-save-entry-and-exit)
  (define-key org-journal-mode-map (kbd "C-c C-j") #'org-journal-new-entry)

  (setq org-journal-file-type 'monthly)
  (setq org-journal-dir "~/journal")
  (setq org-journal-find-file 'find-file)

  ;; 加密 journal 文件。
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
  (setq org-journal-handle-old-carryover 'my-old-carryover)

  ;; journal 文件头。
  (defun org-journal-file-header-func (time)
    "Custom function to create journal header."
    (concat
     (pcase org-journal-file-type
       (`daily "#+TITLE: Daily Journal\n#+STARTUP: showeverything")
       (`weekly "#+TITLE: Weekly Journal\n#+STARTUP: folded")
       (`monthly "#+TITLE: Monthly Journal\n#+STARTUP: folded")
       (`yearly "#+TITLE: Yearly Journal\n#+STARTUP: folded"))))
  (setq org-journal-file-header 'org-journal-file-header-func))

;; 修复报错： org-journal-display-entry: Symbol’s value as variable is void: displayed-month
;; https://github.com/bastibe/org-journal/commit/1de9153f2120e92779d95d9e13f249e98ff1ad14
(defun org-journal-display-entry (_arg &optional event)
  "Display journal entry for selected date in another window."
  (interactive
   (list current-prefix-arg last-nonmenu-event))
  (let* ((time (or (ignore-errors (org-journal-calendar-date->time (calendar-cursor-to-date t event)))
                   (org-time-string-to-time (org-read-date nil nil nil "Date:")))))
    ;; (let* ((time (org-journal--calendar-date->time
    ;;               (calendar-cursor-to-date t event))))
    (org-journal-read-or-display-entry time t)))

(dolist (m '(org-mode org-journal-mode))
  (font-lock-add-keywords m                        ; A bit silly but my headers are now
                          `(("^\\*+ \\(TODO\\) "   ; shorter, and that is nice canceled
                             (1 (progn (compose-region (match-beginning 1) (match-end 1) "⚑") nil)))
                            ("^\\*+ \\(DOING\\) "
                             (1 (progn (compose-region (match-beginning 1) (match-end 1) "⚐") nil)))
                            ("^\\*+ \\(CANCELED\\) "
                             (1 (progn (compose-region (match-beginning 1) (match-end 1) "✘") nil)))
                            ("^\\*+ \\(BLOCKED\\) "
                             (1 (progn (compose-region (match-beginning 1) (match-end 1) "✋") nil)))
                            ("^\\*+ \\(DONE\\) "
                             (1 (progn (compose-region (match-beginning 1) (match-end 1) "✔") nil)))
                            ;; Here is my approach for making the initial asterisks for listing items and
                            ;; whatnot, appear as Unicode bullets ;; (without actually affecting the text
                            ;; file or the behavior).
                            ("^ +\\([-*]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•")))))))

(use-package ox-hugo
  :after ox
  :config
  (setq org-hugo-base-dir "~/blog/blog.opsnull.com")
  (setq org-hugo-section "posts")
  (setq org-hugo-export-with-section-numbers t)
  (setq org-hugo-auto-set-lastmod t))

(setq vc-follow-symlinks t)

(use-package magit
  :straight (magit :repo "magit/magit" :files ("lisp/*.el"))
  :custom
  ;; 在当前 window 中显示 magit buffer。
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  (magit-log-arguments '("-n256" "--graph" "--decorate" "--color"))
  ;; 按照 word 展示 diff。
  (magit-diff-refine-hunk t)
  ;; magit-clone 缺省保存的目录。
  (magit-clone-default-directory "~/go/src/gitlab.alibaba-inc.com/apsara_paas")
  :config
  ;; kill 所有 magit buffer。
  (defun my-magit-kill-buffers (&rest _)
    "Restore window configuration and kill all Magit buffers."
    (interactive)
    (magit-restore-window-configuration)
    (let ((buffers (magit-mode-get-buffers)))
      (when (eq major-mode 'magit-status-mode)
        (mapc (lambda (buf)
                (with-current-buffer buf
                  (if (and magit-this-process
                           (eq (process-status magit-this-process) 'run))
                      (bury-buffer buf)
                    (kill-buffer buf))))
              buffers))))
  (setq magit-bury-buffer-function #'my-magit-kill-buffers)
  ;; diff org-mode 时展开内容。
  (add-hook 'magit-diff-visit-file-hook (lambda() (when (derived-mode-p 'org-mode)(org-fold-show-entry)))))

(use-package git-link :config (setq git-link-use-commit t))

(use-package diff-mode
  :straight (:type built-in)
  :init
  (setq diff-default-read-only t)
  (setq diff-advance-after-apply-hunk t)
  (setq diff-update-on-the-fly t))

(use-package ediff
  :straight (:type built-in)
  :config
  (setq ediff-keep-variants nil)
  (setq ediff-split-window-function 'split-window-horizontally)
  ;; 不创建新的 frame 来显示 Control-Panel。
  (setq ediff-window-setup-function #'ediff-setup-windows-plain))

;; 显示缩进。
(use-package highlight-indent-guides
  :custom
  (highlight-indent-guides-method 'column)
  (highlight-indent-guides-responsive 'top)
  (highlight-indent-guides-suppress-auto-error t)
  :config
  (add-hook 'python-mode-hook 'highlight-indent-guides-mode)
  (add-hook 'python-ts-mode-hook 'highlight-indent-guides-mode)
  (add-hook 'yaml-mode-hook 'highlight-indent-guides-mode)
  (add-hook 'yaml-ts-mode-hook 'highlight-indent-guides-mode)
  (add-hook 'js-mode-hook 'highlight-indent-guides-mode)
  (add-hook 'js-ts-mode-hook 'highlight-indent-guides-mode)
  (add-hook 'web-mode-hook 'highlight-indent-guides-mode))

;; 彩色括号。
(use-package rainbow-delimiters :hook (prog-mode . rainbow-delimiters-mode))

;; 高亮匹配的括号。
(use-package paren
  :straight (:type built-in)
  :hook (after-init . show-paren-mode)
  :init
  (setq show-paren-when-point-inside-paren t
        show-paren-when-point-in-periphery t)
  ;; Highlight blocks of code in bold
  (setq show-paren-style 'parenthesis) ;; parenthesis, expression
  (set-face-attribute 'show-paren-match nil :weight 'extra-bold))

;; 智能括号。
(use-package smartparens
  :config
  (smartparens-global-mode t)
  (show-smartparens-global-mode t))

(use-package envrc :hook (after-init . envrc-global-mode))

(use-package posframe)

;; dump-jump 支持 GNU Global 的 gtags 跳转。
(use-package  dumb-jump
  :demand
  :init
  (setq xref-show-definitions-function #'xref-show-definitions-completing-read)
  :config
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate))

;; 融合 `lsp-bridge' `find-function' 以及 `dumb-jump' 的智能跳转。
(defun lsp-bridge-jump ()
  (interactive)
  (cond
   ((eq major-mode 'emacs-lisp-mode)
    (let ((symb (function-called-at-point)))
      (when symb
        (find-function symb))))
   (lsp-bridge-mode
    (lsp-bridge-find-def))
   (t
    (require 'dumb-jump)
    (dumb-jump-go))))

(defun lsp-bridge-jump-back ()
  (interactive)
  (cond
   (lsp-bridge-mode
    (lsp-bridge-return-from-def))
   (t
    (require 'dumb-jump)
    (dumb-jump-back))))

(use-package lsp-bridge
  :after (markdown-mode)
  :straight (:host github :repo "manateelazycat/lsp-bridge" :files ("*" "acm/*"))
  :custom
  ;; 不在 modeline 显示 lsp-bridge 信息。
  (lsp-bridge-enable-mode-line nil)
  :config
  (setq lsp-bridge-enable-log nil)
  (setq lsp-bridge-enable-signature-help t)
  ;;(setq lsp-bridge-signature-show-function 'lsp-bridge-signature-posframe)
  ;; word 补全。
  (setq acm-enable-search-file-words nil)
  (setq lsp-bridge-enable-search-words nil)
  (setq lsp-bridge-search-words-rebuild-cache-idle 10)
  (setq acm-candidate-match-function 'orderless-flex)
  ;; 至少输入 N 个字符后才开始补全。
  (setq acm-backend-lsp-candidate-min-length 0)
  (setq acm-backend-lsp-enable-auto-import nil)
  (setq acm-backend-lsp-candidate-max-length 100)
  (setq acm-enable-icon nil)
  (setq acm-enable-doc nil)
  (setq acm-enable-telega nil)
  (setq acm-enable-tabnine nil)
  (setq acm-enable-quick-access t)
  (setq lsp-bridge-diagnostic-tooltip-border-width 0)
  (setq lsp-bridge-enable-hover-diagnostic t)
  ;; 关闭 code action 的 popup-menu.
  (setq lsp-bridge-code-action-enable-popup-menu nil)
  (setq lsp-bridge-lookup-doc-tooltip-max-width 100)
  (setq lsp-bridge-lookup-doc-tooltip-border-width 0)
  ;;  过滤 warnning.
  (setq lsp-bridge-diagnostic-hide-severities '(2 3 4))
  ;; 开启 citre 集成。
  (setq acm-enable-citre t)
  ;; 关闭 yas 补全。
  (setq acm-enable-yas nil)
  ;; 增加 treesit 相关的 xx-ts-mode
  (setq lsp-bridge-single-lang-server-mode-list
        '(((c-mode c-ts-mode c++-mode c++-ts-mode objc-mode) . lsp-bridge-c-lsp-server)
          (cmake-mode . "cmake-language-server")
          ((java-mode java-ts-mode) . "jdtls")
          ((python-mode python-ts-mode) . lsp-bridge-python-lsp-server)
          ((go-mode go-ts-mode) . "gopls")
          ((js2-mode js-mode js-ts-mode rjsx-mode) . "javascript")
          (typescript-tsx-mode . "typescriptreact")
          ((typescript-mode typescript-ts-mode) . "typescript")
          ((latex-mode Tex-latex-mode texmode context-mode texinfo-mode bibtex-mode) . lsp-bridge-tex-lsp-server)
          ((sh-mode bash-ts-mode) . "bash-language-server")
          ((css-mode css-ts-mode) . "vscode-css-language-server")
          ((yaml-mode yaml-ts-mode) . "yaml-language-server")
          ((json-mode json-ts-mode) . "vscode-json-language-server")
          ((dockerfile-mode dockerfile-ts-mode) . "docker-langserver")))
  ;; 添加 treesit 相关的 xx-ts-mode-hook 后，lsp-bridge 才会自动启动。
  (add-to-list 'lsp-bridge-default-mode-hooks 'go-ts-mode-hook)
  (add-to-list 'lsp-bridge-default-mode-hooks 'bash-ts-mode-hook)
  (add-to-list 'lsp-bridge-default-mode-hooks 'python-ts-mode-hook)
  (add-to-list 'lsp-bridge-default-mode-hooks 'js-ts-mode-hook)
  (add-to-list 'lsp-bridge-default-mode-hooks 'typescript-ts-mode-hook)
  (add-to-list 'lsp-bridge-default-mode-hooks 'css-ts-mode-hook)
  (add-to-list 'lsp-bridge-default-mode-hooks 'yaml-ts-mode-hook)
  (add-to-list 'lsp-bridge-default-mode-hooks 'json-ts-mode-hook)
  (add-to-list 'lsp-bridge-org-babel-lang-list "emacs-lisp")
  (add-to-list 'lsp-bridge-org-babel-lang-list "sh")
  (add-to-list 'lsp-bridge-org-babel-lang-list "shell")
  (add-to-list 'lsp-bridge-org-babel-lang-list "go")
  ;; go 缩进。
  (add-to-list 'lsp-bridge-formatting-indent-alist '(go-mode . c-basic-offset))
  (add-to-list 'lsp-bridge-formatting-indent-alist '(go-ts-mode . c-basic-offset))
  ;; go 注释字符后不提示补全。
  (add-to-list 'lsp-bridge-completion-hide-characters "/")
  (add-to-list 'lsp-bridge-completion-hide-characters "，")
  (add-to-list 'lsp-bridge-completion-hide-characters "。")
  (global-lsp-bridge-mode)
  ;;; lsp-bridge
  ;; M-j 被预留给 pyim 使用。
  (define-key acm-mode-map (kbd "M-j") nil)
  ;; 使用 TAB 而非回车键来选定。
  ;;(define-key acm-mode-map (kbd "RET") nil)
  (define-key lsp-bridge-mode-map (kbd "M-.") #'lsp-bridge-find-def)
  (define-key lsp-bridge-mode-map (kbd "C-M-.") #'lsp-bridge-find-def-other-window)
  (define-key lsp-bridge-mode-map (kbd "M-,") #'lsp-bridge-find-def-return)
  (define-key lsp-bridge-mode-map (kbd "M-?") #'lsp-bridge-find-references)
  (define-key lsp-bridge-mode-map (kbd "M-d") #'lsp-bridge-popup-documentation)
  ;; 这两个快捷键让位于 symobl-overlay
  ;; (define-key lsp-bridge-mode-map (kbd "M-n") #'lsp-bridge-popup-documentation-scroll-up)
  ;; (define-key lsp-bridge-mode-map (kbd "M-p") #'lsp-bridge-popup-documentation-scroll-down)
  (define-key lsp-bridge-mode-map (kbd "C-c C-a") #'lsp-bridge-code-action)
  (define-key lsp-bridge-mode-map (kbd "C-c C-f") #'lsp-bridge-code-format)
  (define-key lsp-bridge-mode-map (kbd "C-s-d") #'lsp-bridge-diagnostic-list)
  (define-key lsp-bridge-mode-map (kbd "C-s-n") #'lsp-bridge-diagnostic-jump-next)
  (define-key lsp-bridge-mode-map (kbd "C-s-p") #'lsp-bridge-diagnostic-jump-prev))

(defun my/python-setup-shell (&rest args)
  (if (executable-find "ipython")
      (progn
        (setq python-shell-interpreter "ipython")
        (setq python-shell-interpreter-args "--simple-prompt -i"))
    (progn
      (setq python-shell-interpreter "python")
      (setq python-shell-interpreter-args "-i"))))

;; 使用 yapf 格式化 python 代码。
(use-package yapfify :straight (:host github :repo "JorisE/yapfify"))

(use-package python
  :straight (:type built-in)
  :init
  (defvar pyright-directory "~/.emacs.d/.cache/lsp/npm/pyright/lib")
  (if (not (file-exists-p pyright-directory))
      (make-directory pyright-directory t))
  (setq python-indent-guess-indent-offset t)  
  (setq python-indent-guess-indent-offset-verbose nil)
  (setq python-indent-offset 2)
  ;;(with-eval-after-load 'exec-path-from-shell (exec-path-from-shell-copy-env "PYTHONPATH"))
  :hook
  (python-mode . (lambda ()
                   (my/python-setup-shell)
                   (yapf-mode))))

(defun my/go-setup ()
  ;; 如果 GOOS 设置为 linux, 会导致 lsp-bridge 不可用。
  ;;(setenv "GOOS" "linux")
  ;;(setenv "GOARCH" "amd64")
  ;; go-mode 默认启用 tabs.
  (setq indent-tabs-mode t)
  (setq c-ts-common-indent-offset 8)
  (setq c-basic-offset 8))

;; (use-package go-mode
;;   :init
;;   (setq godoc-reuse-buffer t))
;; (add-hook 'go-mode-hook 'my/go-setup)
(add-hook 'go-ts-mode-hook 'my/go-setup)

(defvar go--tools '("golang.org/x/tools/gopls"
                    "golang.org/x/tools/cmd/goimports"
                    "honnef.co/go/tools/cmd/staticcheck"
                    "github.com/go-delve/delve/cmd/dlv"
                    "github.com/zmb3/gogetdoc"
                    "github.com/josharian/impl"
                    "github.com/cweill/gotests/..."
                    "github.com/fatih/gomodifytags"
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
(use-package go-tag
  :init
  (setq go-tag-args (list "-transform" "camelcase"))
  :config
  (define-key go-mode-map (kbd "C-c t a") #'go-tag-add)
  (define-key go-mode-map (kbd "C-c t r") #'go-tag-remove))
(use-package go-playground :commands (go-playground-mode))

(use-package markdown-mode
  :commands (markdown-mode gfm-mode)
  :mode
  (("README\\.md\\'" . gfm-mode) ;; gfm: github flavored markdown.
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
  (setq markdown-css-paths '("https://cdn.jsdelivr.net/npm/github-markdown-css/github-markdown.min.css"
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
  :after (markdown-mode)
  :config
  (setq grip-preview-use-webkit nil)
  ;; 支持网络访问（默认 localhost）。
  (setq grip-preview-host "0.0.0.0")
  ;; 保存文件时才更新预览。
  (setq grip-update-after-change nil)
  ;; 从 ~/.authinfo 文件获取认证信息。
  (require 'auth-source)
  (let ((credential (auth-source-user-and-password "api.github.com")))
    (setq grip-github-user (car credential)
          grip-github-password (cadr credential)))
  ;;; markdown grip-mode
  (define-key markdown-mode-command-map (kbd "g") #'grip-mode))

(use-package markdown-toc
  :after(markdown-mode)
  :config
  (define-key markdown-mode-command-map (kbd "r") #'markdown-toc-generate-or-refresh-toc))

;; for .ts/.tsx file
;; (use-package typescript-mode
;;   :mode "\\.tsx?\\'"
;;   :config
;;   (setq typescript-indent-level 2))
(setq typescript-ts-mode-indent-offset 2)

(use-package js2-mode
  :init
  (add-to-list 'auto-mode-alist '("\\.jsx?\\'" . js-ts-mode))
  :config
  ;; 仍然使用 js-ts-mode 作为 .js/.jsx 的 marjor-mode, 但使用 js2-minor-mode 提供 AST 解析。
  (add-hook 'js-ts-mode-hook 'js2-minor-mode)
  ;; 将 js2-mode 作为 .js/.jsx 的 major-mode
  ;;(add-to-list 'auto-mode-alist '("\\.jsx?\\'" . js2-mode))
  ;; 由于 lsp 已经提供了 diagnose 功能，故关闭 js2 自带的错误检查，防止干扰。
  (setq js2-mode-show-strict-warnings nil)
  (setq js2-mode-show-parse-errors nil)
  ;; 缩进配置。
  (setq javascript-indent-level 2)
  (setq js-indent-level 2)
  (setq js2-basic-offset 2)
  (add-to-list 'interpreter-mode-alist '("node" . js2-mode)))

;; 不再使用第三方 json-mode 包来打开 JSON 文件，内置的 json-ts-mode 性能更高。
;; json mode。
;;(use-package json-mode :straight t :defer t)

(use-package web-mode
  :mode "(\\.\\(jinja2\\|j2\\|css\\|vue\\|tmpl\\|gotmpl\\|html?\\|ejs\\)\\'"
  :disabled ;; 使用内置的 TypeScript mode
  :custom
  (css-indent-offset 2)
  (web-mode-attr-indent-offset 2)
  (web-mode-attr-value-indent-offset 2)
  (web-mode-code-indent-offset 2)
  (web-mode-css-indent-offset 2)
  (web-mode-markup-indent-offset 2)
  (web-mode-sql-indent-offset 2)
  (web-mode-enable-auto-pairing t)
  (web-mode-enable-css-colorization t)
  (web-mode-enable-auto-quoting nil)
  (web-mode-enable-block-face t)
  (web-mode-enable-current-element-highlight t)
  :config
  ;; Emmit.
  (setq web-mode-tag-auto-close-style 2) ;; 2 mean auto-close with > and </.
  (setq web-mode-markup-indent-offset 2))

(use-package yaml-ts-mode
  :straight (:type built-in)
  :mode "\\.ya?ml\\'"
  :config
  (define-key yaml-ts-mode-map (kbd "\C-m") #'newline-and-indent))

(setq sh-basic-offset 2)
(setq sh-indentation 2)

;; Tree-sitter support
;; https://github.com/seagle0128/.emacs.d/blob/master/lisp/init-prog.el
;; @see https://github.com/casouri/tree-sitter-module
;;      https://git.savannah.gnu.org/cgit/emacs.git/tree/admin/notes/tree-sitter/starter-guide?h=feature/tree-sitter
(use-package treesit
  :straight (:type built-in)
  :when (and (fboundp 'treesit-available-p)
             (treesit-available-p))
  ;; :custom (major-mode-remap-alist
  ;;          '((c-mode          . c-ts-mode)
  ;;            (c++-mode        . c++-ts-mode)
  ;;            (cmake-mode      . cmake-ts-mode)
  ;;            (conf-toml-mode  . toml-ts-mode)
  ;;            (css-mode        . css-ts-mode)
  ;;            (dockerfile-mode . dockerfile-ts-mode)
  ;;            (go-mode         . go-ts-mode)
  ;;            (java-mode       . java-ts-mode)
  ;;            (json-mode       . json-ts-mode)
  ;;            (js-json-mode    . json-ts-mode)
  ;;            (js-mode         . js-ts-mode)
  ;;            (python-mode     . python-ts-mode)
  ;;            (rust-mode       . rust-ts-mode)
  ;;            (sh-mode         . bash-ts-mode)
  ;;            (typescript-mode . typescript-ts-mode)))
  ;; :config
  ;; (add-to-list 'auto-mode-alist '("\\(?:CMakeLists\\.txt\\|\\.cmake\\)\\'" . cmake-ts-mode))
  ;; (add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-ts-mode))
  ;; (add-to-list 'auto-mode-alist '("\\.go\\'" . go-ts-mode))
  ;; (add-to-list 'auto-mode-alist '("\\.py\\'" . python-ts-mode))
  ;; (add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-ts-mode))
  ;; (add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
  ;; (add-to-list 'auto-mode-alist '("\\.ya?ml\\'" . yaml-ts-mode))
  )

(use-package treesit-auto
  :straight (treesit-auto :type git :host github :repo "renzmann/treesit-auto")
  :demand t
  :config
  (setq treesit-auto-install nil)
  (global-treesit-auto-mode))

(use-package ts-movement
  :straight (ts-movement :type git :host github :repo "haritkapadia/ts-movement")
  :hook
  (bash-ts-mode-hook . ts-movement-mode)
  (c++-ts-mode-hook . ts-movement-mode)
  (c-ts-mode-hook . ts-movement-mode)
  (cmake-ts-mode-hook . ts-movement-mode)
  (csharp-ts-mode-hook . ts-movement-mode)
  (css-ts-mode-hook . ts-movement-mode)
  (dockerfile-ts-mode-hook . ts-movement-mode)
  (go-ts-mode-hook . ts-movement-mode)
  (java-ts-mode-hook . ts-movement-mode)
  (js-ts-mode-hook . ts-movement-mode)
  (json-ts-mode-hook . ts-movement-mode)
  (python-ts-mode-hook . ts-movement-mode)
  (ruby-ts-mode-hook . ts-movement-mode)
  (rust-ts-mode-hook . ts-movement-mode)
  (toml-ts-mode-hook . ts-movement-mode)
  (tsx-ts-mode-hook . ts-movement-mode)
  (typescript-ts-mode-hook . ts-movement-mode)
  (yaml-ts-mode-hook . ts-movement-mode))

(use-package ts-fold
  :straight (ts-fold :host github :repo "emacs-tree-sitter/ts-fold")
  :disabled
  :config
  (global-ts-fold-mode)
  (global-set-key (kbd "C-c C-<tab>") 'ts-fold-toggle)
  ;; indicators 影响性能；
  ;; (add-hook 'tree-sitter-after-on-hook #'ts-fold-indicators-mode)
  )

;; GNU Global gtags
(setenv "GTAGSOBJDIRPREFIX" (expand-file-name "~/.cache/gtags/"))
;; brew update 可能会更新 Global 版本，故这里使用 glob 匹配版本号。
(setenv "GTAGSCONF" (car (file-expand-wildcards "/usr/local/Cellar/global/*/share/gtags/gtags.conf")))
(setenv "GTAGSLABEL" "pygments")

(use-package citre
  :defer t
  :straight (:host github :repo "universal-ctags/citre")
  :init
  ;; 当打开一个文件时，如果可以找到对应的 TAGS 文件时则自动开启 citre-mode。开启了 citre-mode 后，会自动向
  ;; xref-backend-functions hook 添加 citre-xref-backend，从而支持于 xref 和 imenu 的集成。
  (require 'citre-config)
  :config
  ;; 只使用 GNU Global tags。
  (setq citre-completion-backends '(global))
  (setq citre-find-definition-backends '(global))
  (setq citre-find-reference-backends '(global))
  (setq citre-tags-in-buffer-backends  '(global))
  (setq citre-auto-enable-citre-mode-backends '(global))
  ;; citre-config 的逻辑只对 prog-mode 的文件有效。
  (setq citre-auto-enable-citre-mode-modes '(prog-mode))
  (setq citre-use-project-root-when-creating-tags t)
  (setq citre-peek-file-content-height 20)
  (global-set-key (kbd "s-.") 'citre-jump)
  (global-set-key (kbd "s-,") 'citre-jump-back)
  (global-set-key (kbd "s-?") 'citre-peek-reference) ;; or citre-peek
  (global-set-key (kbd "C-x c u") 'citre-global-update-database))

;; https://gitlab.com/skybert/my-little-friends/-/blob/master/emacs/.emacs#L295

;; Don't ask before killing the current compilation. This is useful if
;; you're running servers after compiling them, so that the compilation never finishes.
(setq compilation-ask-about-save nil
      compilation-always-kill t
      compile-command "go build")
;; Convert shell escapes to color
(add-hook 'compilation-filter-hook
          (lambda () (ansi-color-apply-on-region (point-min) (point-max))))

;; Taken from https://emacs.stackexchange.com/questions/31493/print-elapsed-time-in-compilation-buffer/56130#56130
(make-variable-buffer-local 'my-compilation-start-time)

(add-hook 'compilation-start-hook #'my-compilation-start-hook)
(defun my-compilation-start-hook (proc)
  (setq my-compilation-start-time (current-time)))

(add-hook 'compilation-finish-functions #'my-compilation-finish-function)
(defun my-compilation-finish-function (buf why)
  (let* ((elapsed  (time-subtract nil my-compilation-start-time))
         (msg (format "Compilation took: %s" (format-time-string "%T.%N" elapsed t))))
    (save-excursion (goto-char (point-max)) (insert msg))
    (message "Compilation %s: %s" (string-trim-right why) msg)))

(defun my/goto-compilation()
  (interactive)
  (switch-to-buffer
   (get-buffer-create "*compilation*")))

;; xref 的 history 局限于当前窗口（默认全局）。
(setq xref-history-storage 'xref-window-local-history)

;; 移动到行或代码的开头、结尾。
(use-package mwim
  :config
  (define-key global-map [remap move-beginning-of-line] #'mwim-beginning-of-code-or-line)
  (define-key global-map [remap move-end-of-line] #'mwim-end-of-code-or-line))

;; 开发文档。
(use-package dash-at-point
  :config
  ;; 可以在搜索输入中指定 docset 名称，例如： spf13/viper: getstring
  (global-set-key (kbd "C-c d .") #'dash-at-point)
  ;; 提示选择 docset;
  (global-set-key (kbd "C-c d d") #'dash-at-point-with-docset)
  ;; 扩展提示可选的 docset 列表， 名称必须与 dash 中定义的一致。
  (add-to-list 'dash-at-point-docsets "spf13/viper")
  (add-to-list 'dash-at-point-docsets "spf13/cobra")
  (add-to-list 'dash-at-point-docsets "spf13/pflag")
  (add-to-list 'dash-at-point-docsets "k8s.io/api")
  (add-to-list 'dash-at-point-docsets "k8s.io/apimachineary")
  (add-to-list 'dash-at-point-docsets "k8s.io/client-go")
  (add-to-list 'dash-at-point-docsets "k8s.io/klog")  
  (add-to-list 'dash-at-point-docsets "sig.k8s.io/controller-runtime")
  (add-to-list 'dash-at-point-docsets "k8s.io/componet-base")
  (add-to-list 'dash-at-point-docsets "k8s.io/kubernetes"))

(use-package expand-region
  :init
  (define-advice set-mark-command (:before-while (arg))
    "Repeat C-SPC to expand region."
    (interactive "P")
    (if (eq last-command 'set-mark-command)
        (progn
          (er/expand-region 1)
          nil)
      t))
  :config
  (global-set-key (kbd "C-=") #'er/expand-region))

(use-package shell-maker
  :straight (:host github :repo "xenodium/chatgpt-shell" :files ("shell-maker.el")))

(use-package chatgpt-shell
  :requires shell-maker
  :straight (:host github :repo "xenodium/chatgpt-shell")
  :config
  (setq chatgpt-shell-openai-key
        (auth-source-pick-first-password :host "ai.opsnull.com"))
  (setq chatgpt-shell-chatgpt-streaming t)
  (setq chatgpt-shell-model-version "gpt-4") ;; gpt-3.5-turbo
  (setq chatgpt-shell-request-timeout 300)
  ;; 在另外的 buffer 显示查询结果.
  (setq chatgpt-shell-insert-queries-inline t)
  (require 'ob-chatgpt-shell)
  (ob-chatgpt-shell-setup)
  (require 'ob-dall-e-shell)
  (ob-dall-e-shell-setup)
  (setq chatgpt-shell-api-url-base "http://127.0.0.1:1090")
  ;; (setq chatgpt-shell--url "http://127.0.0.1:1090/v1/chat/completions")
  )

  ;; (setq chatgpt-shell-display-function #'my/chatgpt-shell-frame)

  ;; (defun my/chatgpt-shell-frame (bname)
  ;;   (let ((cur-f (selected-frame))
  ;;         (f (my/find-or-make-frame "chatgpt")))
  ;;     (select-frame-by-name "chatgpt")
  ;;     (pop-to-buffer-same-window bname)
  ;;     (set-frame-position f (/ (display-pixel-width) 2) 0)
  ;;     (set-frame-height f (frame-height cur-f))
  ;;     (set-frame-width f  (frame-width cur-f) 1)))

  ;; (defun my/find-or-make-frame (fname)
  ;;   (condition-case
  ;;       nil
  ;;       (select-frame-by-name fname)
  ;;     (error (make-frame `((name . ,fname))))))

(use-package cue-mode
  :straight (:host github :repo "russell/cue-mode")
  :demand)

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
  (compilation-always-kill t)
  (project-vc-merge-submodules nil)
  :config
  ;; project-find-file 忽略的目录或文件列表。
  (add-to-list 'vc-directory-exclusion-list "vendor")
  (add-to-list 'vc-directory-exclusion-list "node_modules"))

(defun my/project-try-local (dir)
  "Determine if DIR is a non-Git project."
  (catch 'ret
    (let ((pr-flags '((".project")
                      ("go.mod" "pom.xml" "package.json")
                      ;; 以下文件容易导致 project root 判断失败, 故关闭。
                      ;; ("Makefile" "README.org" "README.md")
                      )))
      (dolist (current-level pr-flags)
        (dolist (f current-level)
          (when-let ((root (locate-dominating-file dir f)))
            (throw 'ret (cons 'local root))))))))

(setq project-find-functions '(my/project-try-local project-try-vc))

(cl-defmethod project-root ((project (head local)))
  (cdr project))

(defun my/project-info ()
  (interactive)
  (message "%s" (project-current t)))

(defun my/project-add (dir)
  (interactive "DDirectory: \n")
  ;; 使用 project-remember-project 报错。
  (project-remember-projects-under dir nil))

(defun my/project-new-root ()
  (interactive)
  (let* ((root-dir (read-directory-name "Root: "))
         (f (expand-file-name ".project" root-dir)))
    (message "Create %s..." f)
    (make-directory root-dir t)
    (when (not (file-exists-p f))
      (make-empty-file f))
    (my/project-add root-dir)))

(defun my/project-discover ()
  (interactive)
  ;; 去掉 "~/go/src/k8s.io/*" 目录。
  (dolist (search-path '("~/go/src/github.com/*" "~/go/src/github.com/*/*" "~/go/src/gitlab.*/*/*"))
    (dolist (file (file-expand-wildcards search-path))
      (when (file-directory-p file)
          (message "dir %s" file)
          ;; project-remember-projects-under 列出 file 下的目录, 分别加到 project-list-file 中。
          (project-remember-projects-under file nil)
          (message "added project %s" file)))))

;; 不将 tramp 项目记录到 projects 文件中，防止 emacs-dashboard 启动时检查 project 卡住。
(defun my/project-remember-advice (fn pr &optional no-write)
  (let* ((remote? (file-remote-p (project-root pr)))
         (no-write (if remote? t no-write)))
    (funcall fn pr no-write)))
(advice-add 'project-remember-project :around 'my/project-remember-advice)

;; 添加环境变量 
(setq my/socks-host "127.0.0.1")
(setq my/socks-port 1080)
;; socks5h 相比 socks5 会额外代理域名解析，解决域名投毒问题。
(setq my/socks-proxy (format "socks5h://%s:%d" my/socks-host my/socks-port))

(use-package mb-url-http
  :demand
  :straight (mb-url :repo "dochang/mb-url")
  :commands (mb-url-http-around-advice)
  :init
  (require 'auth-source)
  (let ((credential (auth-source-user-and-password "api.github.com")))
    (setq github-user (car credential)
          github-password (cadr credential))
    (setq github-auth (concat github-user ":" github-password))
    (setq mb-url-http-backend 'mb-url-http-curl
          mb-url-http-curl-program "/usr/local/opt/curl/bin/curl"
          mb-url-http-curl-switches `("-k" "-x" ,my/socks-proxy
                                      ;;"--max-time" "300"
                                      ;;"-u" ,github-auth
                                      ;;"--user-agent" "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36"
                                      ))))

(defun proxy-socks-show ()
  "Show SOCKS proxy."
  (interactive)
  (when (fboundp 'cadddr)
    (if (bound-and-true-p socks-noproxy)
        (message "Current SOCKS%d proxy is %s:%d" 5 my/socks-host my/socks-port)
      (message "No SOCKS proxy"))))

(defun proxy-socks-enable ()
  "使用 socks 代理 url 访问请求。"
  (interactive)
  (require 'socks)
  (setq url-gateway-method 'socks
        socks-noproxy '("0.0.0.0" "localhost" "10.0.0.0/8" "172.0.0.0/8" "*cn" "*alibaba-inc.com" "*taobao.com" "*antfin-inc.com")
        socks-server `("Default server" ,my/socks-host ,my/socks-port 5))
  (setenv "all_proxy" my/socks-proxy)
  (setenv "ALL_PROXY" my/socks-proxy)
  (setenv "HTTP_PROXY" nil)
  (setenv "HTTPS_PROXY" nil)
  (proxy-socks-show)
  ;;url-retrieve 使用 curl 作为后端实现, 支持全局 socks5 代理。
  (advice-add 'url-http :around 'mb-url-http-around-advice))

(defun proxy-socks-disable ()
  "Disable SOCKS proxy."
  (interactive)
  (require 'socks)
  (setq url-gateway-method 'native
        socks-noproxy nil)
  (setenv "all_proxy" "")
  (setenv "ALL_PROXY" "")
  (proxy-socks-show))

(defun proxy-socks-toggle ()
  "Toggle SOCKS proxy."
  (interactive)
  (require 'socks)
  (if (bound-and-true-p socks-noproxy)
      (proxy-socks-disable)
    (proxy-socks-enable)))

(use-package vterm
  :hook
  ;; vterm buffer 使用 fixed pitch 的 mono 字体，否则部分终端表格之类的程序会对不齐。
  (vterm-mode . (lambda ()
                  (set (make-local-variable 'buffer-face-mode-face) 'fixed-pitch)
                  (buffer-face-mode t)))
  :config
  (setq vterm-set-bold-hightbright t)
  (setq vterm-always-compile-module t)
  (setq vterm-max-scrollback 100000)
  (add-to-list 'vterm-tramp-shells '("ssh" "/bin/bash"))
  ;; vterm buffer 名称，需要配置 shell 来支持（如 bash 的 PROMPT_COMMAND）。
  (setq vterm-buffer-name-string "*vterm: %s")
  (add-hook 'vterm-mode-hook
            (lambda ()
              (setf truncate-lines nil)
              (setq-local show-paren-mode nil)
              (setq-local global-hl-line-mode nil)
              (yas-minor-mode -1)))
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
  ;; 切换到一个空闲的 vterm buffer 并插入一个 cd 命令， 或者创建一个新的 vterm buffer 。
  (define-key vterm-mode-map (kbd "s-i") 'vterm-toggle-cd-show)
  (define-key vterm-mode-map (kbd "s-n") 'vterm-toggle-forward)
  (define-key vterm-mode-map (kbd "s-p") 'vterm-toggle-backward)
  (define-key vterm-copy-mode-map (kbd "s-i") 'vterm-toggle-cd-show)
  (define-key vterm-copy-mode-map (kbd "s-n") 'vterm-toggle-forward)
  (define-key vterm-copy-mode-map (kbd "s-p") 'vterm-toggle-backward))

(use-package vterm-extra
  :straight (:host github :repo "Sbozzolo/vterm-extra")
  :config
  ;;(advice-add #'vterm-extra-edit-done :after #'winner-undo)
  (define-key vterm-mode-map (kbd "C-c C-e") #'vterm-extra-edit-command-in-new-buffer))

;; 在 $HOME 目录打开一个本地 vterm buffer.
(defun my/vterm()
  "my vterm buff."
  (interactive)
  (let ((default-directory "~/")) (vterm)))

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

(use-package tramp
  :straight (:type built-in)
  ;;:straight (tramp :files ("lisp/*"))
  :config
  ;; 使用远程主机自己的 PATH(默认是本地的 PATH)
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path)
  ;; 使用 ~/.ssh/config 中的 ssh 持久化配置。（Emacs 默认复用连接，但不持久化连接）
  (setq  tramp-ssh-controlmaster-options nil)
  ;; TRAMP buffers 关闭 version control, 防止卡住。
  (setq vc-ignore-dir-regexp (format "\\(%s\\)\\|\\(%s\\)" vc-ignore-dir-regexp tramp-file-name-regexp))
  ;; 关闭自动保存 ad-hoc proxy 代理配置, 防止为相同 IP 的 VM 配置了错误的 Proxy.
  (setq tramp-save-ad-hoc-proxies nil)
  ;; 调大远程文件名过期时间（默认 10s), 提高查找远程文件性能.
  (setq remote-file-name-inhibit-cache 1800)
  ;;tramp-verbose 10
  (setq tramp-verbose 0)
  ;; 增加压缩传输的文件起始大小（默认 4KB），否则容易出错： “gzip: (stdin): unexpected end of file”
  (setq tramp-inline-compress-start-size (* 1024 8))
  ;; 当文件大小超过 tramp-copy-size-limit 时，用 external methods(如 scp）来传输，从而大大提高拷贝效率。
  (setq tramp-copy-size-limit (* 1024 1024 2))
  (setq tramp-allow-unsafe-temporary-files t)
  ;; 本地不保存 tramp 备份文件。
  (setq tramp-backup-directory-alist `((".*" .  nil)))
  ;; Backup (file~) disabled and auto-save (#file#) locally to prevent delays in editing remote files
  ;; https://stackoverflow.com/a/22077775
  (add-to-list 'backup-directory-alist (cons tramp-file-name-regexp nil))
  ;; 临时目录中保存 TRAMP auto-save 文件, 重启后清空，防止启动时 tramp 扫描文件卡住。
  (setq tramp-auto-save-directory temporary-file-directory)
  ;; 连接历史文件。
  (setq tramp-persistency-file-name (expand-file-name "tramp-connection-history" user-emacs-directory))
  ;; 避免在 shell history 中添加过多 vterm 自动执行的命令。
  (setq tramp-histfile-override nil)
  ;; 在整个 Emacs session 期间保存 SSH 密码.
  (setq password-cache-expiry nil)
  (setq tramp-default-method "ssh")
  (setq tramp-default-remote-shell "/bin/bash")
  (setq tramp-encoding-shell "/bin/bash")
  (setq tramp-default-user "root")
  (setq tramp-terminal-type "tramp")
  (customize-set-variable 'tramp-encoding-shell "/bin/bash")
  (add-to-list 'tramp-connection-properties '("/ssh:" "remote-shell" "/bin/bash"))
  (setq tramp-connection-local-default-shell-variables
        '((shell-file-name . "/bin/bash")
          (shell-command-switch . "-c")))
  
  ;; 自定义远程环境变量。
  (let ((process-environment tramp-remote-process-environment))
    ;; 设置远程环境变量 VTERM_TRAMP, 远程机器的 emacs_bashrc 根据这个变量设置 VTERM 参数。
    (setenv "VTERM_TRAMP" "true")
    (setq tramp-remote-process-environment process-environment)))

;; 切换 Buffer 时设置 VTERM_HOSTNAME 环境变量为多跳的最后一个主机名，并通过 vterm-environment 传递到远程 vterm shell 环境变量中，
;; 这样远程机器 ~/.bashrc 读取并执行的 emacs_bashrc 脚本正确设置 Buffer 名称和 vtem_prompt_end 函数, 从而确保目录跟踪功能正常,
;; 以及通过主机名而非 IP 来打开远程 vterm shell, 确保 SSH ProxyJump 功能正常（只能通过主机名而非 IP 访问），以及避免目标 IP 重复时
;; 连接复用错误的问题。
(defvar my/remote-host "")
(add-hook 'buffer-list-update-hook
          (lambda ()
            (when (file-remote-p default-directory)
              (setq my/remote-host (file-remote-p default-directory 'host))
              ;; 动态计算 ENV=VALUE.
              (require 'vterm)
              (setq vterm-environment `(,(concat "VTERM_HOSTNAME=" my/remote-host))))))

(use-package consult-tramp
  :straight (:repo "Ladicle/consult-tramp" :host github)
  :custom
  ;; 默认为 scpx 模式，不支持 SSH 多跳 Jump。
  (consult-tramp-method "ssh")
  ;; 打开远程的 /root 目录，而非 ~, 避免 tramp hang。
  ;; https://lists.gnu.org/archive/html/bug-gnu-emacs/2007-07/msg00006.html
  (consult-tramp-path "/root/")
  ;; 即使 ~/.ssh/config 正确 Include 了 hosts 文件，这里还是需要配置，因为 consult-tramp 不会解析 Include 配置。
  (consult-tramp-ssh-config "~/work/proxylist/hosts_config"))

(use-package elfeed
  :demand
  :config
  (setq elfeed-db-directory (expand-file-name "elfeed" user-emacs-directory))
  (setq elfeed-show-entry-switch 'display-buffer)
  (setq elfeed-curl-max-connections 32)
  (setq elfeed-curl-timeout 60)
  (setf url-queue-timeout 120)
  (push "-k" elfeed-curl-extra-arguments)
  (setq elfeed-search-filter "@1-months-ago +unread")
  ;; 在同一个 buffer 中显示条目。
  (setq elfeed-show-unique-buffers nil)
  (setq elfeed-search-title-max-width 150)
  (setq elfeed-search-date-format '("%Y-%m-%d %H:%M" 20 :left))
  (setq elfeed-log-level 'warn)

  ;; 支持收藏 feed, 参考：http://pragmaticemacs.com/emacs/star-and-unstar-articles-in-elfeed/
  (defalias 'elfeed-toggle-star (elfeed-expose #'elfeed-search-toggle-all 'star))
  (eval-after-load 'elfeed-search '(define-key elfeed-search-mode-map (kbd "m") 'elfeed-toggle-star))
  (defface elfeed-search-star-title-face '((t :foreground "#f77")) "Marks a starred Elfeed entry.")
  (push '(star elfeed-search-star-title-face) elfeed-search-face-alist))

(use-package elfeed-org
  :custom ((rmh-elfeed-org-files (list "~/.emacs.d/elfeed.org")))
  :hook
  ((elfeed-dashboard-mode . elfeed-org)
   (elfeed-show-mode . elfeed-org))
  :config
  (progn
    (defun my/reload-org-feeds ()
      (interactive)
      (rmh-elfeed-org-process rmh-elfeed-org-files rmh-elfeed-org-tree-id))
    (advice-add 'elfeed-dashboard-update :before #'my/reload-org-feeds)))

(use-package elfeed-dashboard
  :config
  (global-set-key (kbd "C-c f") 'elfeed-dashboard)
  ;; dashboard 配置，例如各种 feed 查询书签。
  (setq elfeed-dashboard-file "~/.emacs.d/elfeed-dashboard.org")
  (advice-add 'elfeed-search-quit-window :after #'elfeed-dashboard-update-links))

(use-package elfeed-score
  :config
  (progn
    (elfeed-score-enable)
    (define-key elfeed-search-mode-map "=" elfeed-score-map)))

(use-package elfeed-goodies
  :config
  (setq elfeed-goodies/entry-pane-position 'bottom)
  (setq elfeed-goodies/feed-source-column-width 30)
  (setq elfeed-goodies/tag-column-width 30)
  (setq elfeed-goodies/powerline-default-separator 'arrow)
  (elfeed-goodies/setup))

;; elfeed-goodies 显示日期栏
;;https://github.com/algernon/elfeed-goodies/issues/15#issuecomment-243358901
(defun elfeed-goodies/search-header-draw ()
  "Returns the string to be used as the Elfeed header."
  (if (zerop (elfeed-db-last-update))
      (elfeed-search--intro-header)
    (let* ((separator-left (intern (format "powerline-%s-%s"
                                           elfeed-goodies/powerline-default-separator
                                           (car powerline-default-separator-dir))))
           (separator-right (intern (format "powerline-%s-%s"
                                            elfeed-goodies/powerline-default-separator
                                            (cdr powerline-default-separator-dir))))
           (db-time (seconds-to-time (elfeed-db-last-update)))
           (stats (-elfeed/feed-stats))
           (search-filter (cond
                           (elfeed-search-filter-active
                            "")
                           (elfeed-search-filter
                            elfeed-search-filter)
                           (""))))
      (if (>= (window-width) (* (frame-width) elfeed-goodies/wide-threshold))
          (search-header/draw-wide separator-left separator-right search-filter stats db-time)
        (search-header/draw-tight separator-left separator-right search-filter stats db-time)))))

(defun elfeed-goodies/entry-line-draw (entry)
  "Print ENTRY to the buffer."
  (let* ((title (or (elfeed-meta entry :title) (elfeed-entry-title entry) ""))
         (date (elfeed-search-format-date (elfeed-entry-date entry)))
         (title-faces (elfeed-search--faces (elfeed-entry-tags entry)))
         (feed (elfeed-entry-feed entry))
         (feed-title
          (when feed
            (or (elfeed-meta feed :title) (elfeed-feed-title feed))))
         (tags (mapcar #'symbol-name (elfeed-entry-tags entry)))
         (tags-str (concat "[" (mapconcat 'identity tags ",") "]"))
         (title-width (- (window-width) elfeed-goodies/feed-source-column-width
                         elfeed-goodies/tag-column-width 4))
         (title-column (elfeed-format-column
                        title (elfeed-clamp
                               elfeed-search-title-min-width
                               title-width
                               title-width)
                        :left))
         (tag-column (elfeed-format-column
                      tags-str (elfeed-clamp (length tags-str)
                                             elfeed-goodies/tag-column-width
                                             elfeed-goodies/tag-column-width)
                      :left))
         (feed-column (elfeed-format-column
                       feed-title (elfeed-clamp elfeed-goodies/feed-source-column-width
                                                elfeed-goodies/feed-source-column-width
                                                elfeed-goodies/feed-source-column-width)
                       :left)))

    (if (>= (window-width) (* (frame-width) elfeed-goodies/wide-threshold))
        (progn
          (insert (propertize date 'face 'elfeed-search-date-face) " ")
          (insert (propertize feed-column 'face 'elfeed-search-feed-face) " ")
          (insert (propertize tag-column 'face 'elfeed-search-tag-face) " ")
          (insert (propertize title 'face title-faces 'kbd-help title)))
      (insert (propertize title 'face title-faces 'kbd-help title)))))

;;; Google 翻译
(use-package google-translate
  :straight (:host github :repo "atykhonov/google-translate")
  :config
  (setq max-mini-window-height 0.2)
  ;;(setq google-translate-output-destination 'popup)
  ;;(setq google-translate-output-destination 'kill-ring)
  ;; C-n/p 切换翻译类型。
  (setq google-translate-translation-directions-alist
        '(("en" . "zh-CN") ("zh-CN" . "en")))
  (global-set-key (kbd "C-c d t") #'google-translate-smooth-translate))

;; 增加 imenu 行内容长度。
;;(setq imenu-max-item-length 160)

(setq tab-width 4)
;; 不插入 tab (按照 tab-width 转换为空格插入) 。
(setq-default indent-tabs-mode nil)

;; 保存 Buffer 时自动更新 #+LASTMOD: 时间戳。
(setq time-stamp-start "#\\+\\(LASTMOD\\|lastmod\\):[ \t]*")
(setq time-stamp-end "$")
(setq time-stamp-format "%Y-%m-%dT%02H:%02m:%02S%5z")
;; #+LASTMOD: 必须位于文件开头的 line-limit 行内, 否则自动更新不生效。
(setq time-stamp-line-limit 30)
(add-hook 'before-save-hook 'time-stamp t)

;; 使用 fundamental-mode 打开大文件。
(defun my/large-file-hook ()
  (when (or (string-equal (file-name-extension (buffer-file-name)) "json")
            (string-equal (file-name-extension (buffer-file-name)) "yaml")
            (string-equal (file-name-extension (buffer-file-name)) "yml")
            (string-equal (file-name-extension (buffer-file-name)) "log"))
    (setq buffer-read-only t)
    (font-lock-mode -1)
    (yas-minor-mode -1)
    (smartparens-mode -1)
    (show-smartparens-mode -1)
    (show-paren-mode -1)
    (js2-minor-mode -1)
    ;;(fira-code-mode -1)
    (prettify-symbols-mode -1)
    ;;(symbol-overlay-mode -1)
    (lsp-bridge-mode -1)
    (display-line-numbers-mode -1)
    (highlight-indent-guides-mode -1)
    (visual-fill-column-mode -1)
    (rainbow-delimiters-mode -1)))
(add-hook 'find-file-hook 'my/large-file-hook)

(use-package emacs
  :straight (:type built-in)
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

(use-package ibuffer
  :straight (:type built-in)
  :config
  (setq ibuffer-expert t)
  (setq ibuffer-use-other-window t)
  (setq ibuffer-movement-cycle nil)
  (setq ibuffer-default-sorting-mode 'recency)
  (setq ibuffer-use-header-line t)
  (add-hook 'ibuffer-mode-hook #'hl-line-mode)
  (global-set-key (kbd "C-x C-b") #'ibuffer))

(use-package recentf
  :straight (:type built-in)
  :config
  (setq recentf-save-file "~/.emacs.d/recentf")
  ;; 不自动清理 recentf 记录。
  (setq recentf-auto-cleanup 'never)
  ;; emacs 退出时清理 recentf 记录。
  (add-hook 'kill-emacs-hook #'recentf-cleanup)
  ;; 每 5min 以及 emacs 退出时保存 recentf-list。
  ;;(run-at-time nil (* 5 60) 'recentf-save-list)
  ;;(add-hook 'kill-emacs-hook #'recentf-save-list)
  (setq recentf-max-menu-items 100)
  (setq recentf-max-saved-items 200) ;; default 20
  ;; recentf-exclude 的参数是正则表达式列表，不支持 ~ 引用家目录。
  ;; emacs-dashboard 不显示这里排除的文件。
  
  (setq recentf-exclude `(,(recentf-expand-file-name "~\\(straight\\|ln-cache\\|etc\\|var\\|.cache\\|backup\\|elfeed\\)/.*")
                          ,(recentf-expand-file-name "~\\(recentf\\|bookmarks\\|archived.org\\)")
                          ,tramp-file-name-regexp ;; 不在 recentf 中记录 tramp 文件，防止 tramp 扫描时卡住。
                          "^/tmp" "\\.bak\\'" "\\.gpg\\'" "\\.gz\\'" "\\.tgz\\'" "\\.xz\\'" "\\.zip\\'" "^/ssh:" "\\.png\\'"
                          "\\.jpg\\'" "/\\.git/" "\\.gitignore\\'" "\\.log\\'" "COMMIT_EDITMSG" "\\.pyi\\'" "\\.pyc\\'"
                          "/private/var/.*" "^/usr/local/Cellar/.*" ".*/vendor/.*"
                          ,(concat package-user-dir "/.*-autoloads\\.egl\\'")))
  (recentf-mode +1))

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

(defvar autosave-dir (expand-file-name "~/.emacs.d/autosave/"))
(if (not (file-exists-p autosave-dir))
    (make-directory autosave-dir t))
;; auto-save 访问的文件。
(setq auto-save-default t)
(setq auto-save-list-file-prefix autosave-dir)
(setq auto-save-file-name-transforms `((".*" ,autosave-dir t)))

;; Revert
;;(global-set-key (kbd "<f5>") #'revert-buffer)
(global-auto-revert-mode 1)
(setq revert-without-query (list "\\.png$" "\\.svg$")
      auto-revert-verbose nil)

(setq global-mark-ring-max 100)
(setq mark-ring-max 100 )
(setq kill-ring-max 100)

;; minibuffer 历史记录。
(use-package savehist
  :straight (:type built-in)
  :hook (after-init . savehist-mode)
  :config
  (setq history-length 600)
  (setq savehist-save-minibuffer-history t)
  (setq savehist-autosave-interval 200)
  (setq savehist-additional-variables
        '(mark-ring
          global-mark-ring
          extended-command-history)))

;; fill-column 的值应该小于 visual-fill-column-width，否则居中显示时行内容会过长而被隐藏。
(setq-default fill-column 100)
(setq-default comment-fill-column 0)
(setq-default message-log-max t)
(setq-default ad-redefinition-action 'accept)

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
(set-default buffer-file-coding-system 'utf8)
(set-default-coding-systems 'utf-8)
(setenv "LC_ALL" "zh_CN.UTF-8")

;; 删除文件时, 将文件移动到回收站。
(use-package osx-trash
  :config
  (when (eq system-type 'darwin)
    (osx-trash-setup))
  (setq-default delete-by-moving-to-trash t))

;; 在 Finder 中打开当前文件。
(use-package reveal-in-osx-finder :commands (reveal-in-osx-finder))

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

;; 在另一个 panel buffer 中展示按键。
(use-package command-log-mode :commands command-log-mode)
(use-package hydra :commands defhydra)

;; macOS 按键调整。
(setq mac-command-modifier 'meta)
;; option 作为 Super 键(按键绑定时： s- 表示 Super，S- 表示 Shift, H- 表示 Hyper)。
(setq mac-option-modifier 'super)
;; fn 作为 Hyper 键。
(setq ns-function-modifier 'hyper)

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
;; Rename current buffer, as well as doing the related version control
;; commands to rename the file.
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

;; 创建名为 *tmp-<N>* 的临时 buffer;
(defun create-temp-buffer ()
  "Create a new temporary buffer with a specific prefix."
  (interactive)
  (let ((temp-buffer-prefix "tmp-")
        (buffer-counter 1))
    (while (get-buffer (format "*%s%d*" temp-buffer-prefix buffer-counter))
      (setq buffer-counter (1+ buffer-counter)))
    (switch-to-buffer (format "*%s%d*" temp-buffer-prefix buffer-counter))))

(global-set-key (kbd "C-c t") 'create-temp-buffer)

(defun my/insert-date ()
  (interactive)
  (let (( time (current-time-string) ))
    (insert (format-time-string "%Y-%m-%d"))))
