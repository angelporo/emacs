(require 'package)
(setq package-archives '(("elpa" . "https://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")))

;; 配置 use-package 默认使用 straight 安装包：
(setq straight-use-package-by-default t)
(setq straight-vc-git-default-clone-depth 1)
(setq straight-recipes-gnu-elpa-use-mirror t)
(setq straight-check-for-modifications '(check-on-save find-when-checking watch-files))
(setq straight-host-usernames '((github . "opsnull")))

;; 安装 straight.el:
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; 安装 use-package 。
(straight-use-package 'use-package)
(setq use-package-verbose t)
(setq use-package-compute-statistics t)

;; 为 use-package 添加 :ensure-system-package 指令。
(use-package use-package-ensure-system-package)

(use-package exec-path-from-shell
  :demand
  :custom
  (exec-path-from-shell-check-startup-files nil)
  (exec-path-from-shell-variables '("PATH" "MANPATH" "GOPATH" "GOPROXY" "GOPRIVATE" "GOFLAGS" "GO111MODULE"))
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

;; 提升 IO 性能。
(setq process-adaptive-read-buffering nil)
;; 增加单次读取进程输出的数据量（缺省 4KB) 。
(setq read-process-output-max (* 1024 1024))

;; 提升长行处理性能。
(setq bidi-inhibit-bpa t)
(setq-default bidi-display-reordering 'left-to-right)
(setq-default bidi-paragraph-direction 'left-to-right)

;; 缩短 fontify 时间。
(setq jit-lock-defer-time nil)
(setq jit-lock-context-time 0.1)
;; 更积极的 fontify 。
(setq fast-but-imprecise-scrolling nil)
(setq redisplay-skip-fontification-on-input nil)

;; 缩短更新 screen 的时间。
(setq idle-update-delay 0.1)

;; 使用字体缓存，避免卡顿。
(setq inhibit-compacting-font-caches t)

;; Garbage Collector Magic Hack
(use-package gcmh
  :demand
  :init
  ;; 在 minibuffer 显示 GC 信息。
  ;;(setq garbage-collection-messages t)
  ;;(setq gcmh-verbose t)
  (setq gcmh-idle-delay 5)
  (setq gcmh-high-cons-threshold (* 64 1024 1024))
  (gcmh-mode 1)
  (gcmh-set-high-threshold))

;; 关闭各种图形元素。
(when (window-system)
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (menu-bar-mode -1))

;; 关闭启动消息。
(setq inhibit-startup-screen t)
(setq inhibit-startup-message t)
(setq inhibit-startup-echo-area-message t)
(setq initial-scratch-message nil)

;; 指针不闪动。
(blink-cursor-mode -1)

;; 未选中窗口。
(setq-default cursor-in-non-selected-windows nil)
(setq highlight-nonselected-windows nil)

;; 关闭对话框。
(setq use-file-dialog nil)
(setq use-dialog-box nil)

;; 窗口间显示分割线。
(setq window-divider-default-places t)
(add-hook 'window-setup-hook #'window-divider-mode)

;; 分屏时使用左右分屏, nil: 上下分屏。
(setq split-width-threshold 30)

;; 复用当前 frame 。
(setq display-buffer-reuse-frames t)

(when (memq window-system '(mac ns x))
  ;; 使用更瘦字体。
  (setq ns-use-thin-smoothing t)
  ;; 不在新 frame 打开文件（如 Finder 的 "Open with Emacs") 。
  (setq ns-pop-up-frames nil)
  ;; 一次滚动一行，避免窗口跳动。
  (setq mouse-wheel-scroll-amount '(1 ((shift) . hscroll))
        mouse-wheel-scroll-amount-horizontal 1
        mouse-wheel-follow-mouse t
        mouse-wheel-progressive-speed nil)
  (xterm-mouse-mode t))

(setq auto-window-vscroll nil)

;; 滚动一屏后, 显示 5 行上下文。
(setq next-screen-context-lines 5)

;; 平滑地进行半屏滚动，避免滚动后 recenter 操作。
(setq scroll-step 1)
(setq scroll-conservatively 10000)
(setq scroll-margin 2)

;; 滚动时保持光标位置。
(setq scroll-preserve-screen-position 1)

(if (boundp 'pixel-scroll-precision-mode)
    (pixel-scroll-precision-mode t))

;; 关闭 mouse-wheel-text-scale 快捷键 (容易触碰误操作) 。
(global-unset-key (kbd "C-<wheel-down>"))
(global-unset-key (kbd "C-<wheel-up>"))

;; 大文件不显示行号。
(setq large-file-warning-threshold nil)
(setq line-number-display-limit large-file-warning-threshold)
(setq line-number-display-limit-width 1000)
(dolist (mode '(text-mode-hook prog-mode-hook conf-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 1))))

;; 自动根据窗口大小显示图片。
(setq image-transform-resize t)
(auto-image-file-mode t)

;; 显示缩进。
(use-package highlight-indent-guides
  :custom
  (highlight-indent-guides-method 'character)
  (highlight-indent-guides-responsive 'top)
  (highlight-indent-guides-suppress-auto-error t)
  (highlight-indent-guides-delay 0.1)
  :config
  (add-hook 'python-mode-hook 'highlight-indent-guides-mode)
  (add-hook 'yaml-mode-hook 'highlight-indent-guides-mode)
  (add-hook 'js-mode-hook 'highlight-indent-guides-mode)
  (add-hook 'web-mode-hook 'highlight-indent-guides-mode))

;; 高亮粘贴的内容。
(use-package volatile-highlights
  :after(undo-tree)
  :config
  (volatile-highlights-mode t)
  (vhl/define-extension 'undo-tree 'undo-tree-yank 'undo-tree-move)
  (vhl/install-extension 'undo-tree))

;; 预览主题: https://emacsthemes.com/
(use-package doom-themes
  :demand
  ;; 添加 "extensions/*" 后才支持 visual-bell/treemacs/org 配置。
  :straight (:files ("*.el" "themes/*" "extensions/*"))
  :custom-face
  (doom-modeline-buffer-file ((t (:inherit (mode-line bold)))))
  :custom
  (doom-themes-enable-bold t)
  (doom-themes-enable-italic t)
  (doom-themes-treemacs-theme "doom-colors")
  ;; modeline 两边各加 4px 空白。
  (doom-themes-padded-modeline t)
  :config
  ;;(load-theme 'doom-palenight t)
  (doom-themes-visual-bell-config)
  (doom-themes-treemacs-config)
  (doom-themes-org-config))

;; 跟随 Mac 自动切换深浅主题。
(defun my/load-light-theme () (interactive) (load-theme 'doom-one-light t))
(defun my/load-dark-theme () (interactive) (load-theme 'doom-vibrant t))
(add-hook 'ns-system-appearance-change-functions
          (lambda (appearance)
            (pcase appearance
              ('light (my/load-light-theme))
              ('dark (my/load-dark-theme)))))

;; modeline 显示电池和日期时间。
(display-battery-mode t)
(column-number-mode t)
(size-indication-mode -1)
(display-time-mode t)
(setq display-time-24hr-format t)
(setq display-time-default-load-average nil)
(setq display-time-load-average-threshold 5)
(setq display-time-format "%m/%dT%H:%M")
(setq display-time-day-and-date t)
(setq indicate-buffer-boundaries (quote left))

(use-package doom-modeline
  :demand
  :after(doom-themes)
  :custom
  ;; 不显示换行和编码（节省空间）。
  (doom-modeline-buffer-encoding nil)
  ;; 使用 HUD 显式光标位置。
  ;;(doom-modeline-hud t)
  ;; 显示语言版本。
  (doom-modeline-env-version t)
  ;; 不显示 Go 版本。
  (doom-modeline-env-enable-go nil)
  (doom-modeline-unicode-fallback t)
  ;; 不显示 project 名称。
  ;;(doom-modeline-project-detection nil)
  ;; 不显示文件所属项目，否则 TRAMP 变慢：https://github.com/seagle0128/doom-modeline/issues/32
  ;;(doom-modeline-buffer-file-name-style 'file-name)
  (doom-modeline-buffer-file-name-style 'relative-from-project)
  (doom-modeline-vcs-max-length 30)
  (doom-modeline-github nil)
  (doom-modeline-height 2)
  :init
  (doom-modeline-mode 1)
  :config
  (doom-modeline-def-modeline 'main
    ;; left-hand segment list, 去掉 remote-host，避免 TRAMP 卡住。
    '(bar workspace-name window-number modals matches buffer-info buffer-position word-count parrot selection-info)
    ;; right-hand segment list，尾部增加空格，避免 modeline 溢出。
    '(objed-state misc-info battery grip debug repl lsp minor-modes input-method major-mode process vcs checker " ")))

(use-package dashboard
  :demand
  :after (projectile)
  :config
  (setq dashboard-banner-logo-title "Happy Hacking & Writing 🎯")
  ;;(setq dashboard-startup-banner (expand-file-name "~/.emacs.d/emacs-e.svg"))
  (setq dashboard-projects-backend #'projectile)
  (setq dashboard-center-content t)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-navigator t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-items '((recents . 10) (projects . 8) (agenda . 3)))
  (dashboard-setup-startup-hook))

(use-package centaur-tabs
  :hook (emacs-startup . centaur-tabs-mode)
  :init
  (setq centaur-tabs-set-icons t)
  (setq centaur-tabs-height 25)
  (setq centaur-tabs-gray-out-icons 'buffer)
  (setq centaur-tabs-set-modified-marker t)
  (setq centaur-tabs-cycle-scope 'tabs)
  (setq centaur-tabs-enable-ido-completion nil)
  (setq centaur-tabs-set-bar 'under)
  (setq x-underline-at-descent-line t)
  (setq centaur-tabs-show-navigation-buttons t)
  (setq centaur-tabs-enable-key-bindings t)
  :bind
  (("C-c t f" . centaur-tabs-forward)
   ("C-c t b" . centaur-tabs-backward)
   ;; 将 buffer 按 projectile 分组。
   ("C-c t p" . centaur-tabs-group-by-projectile-project)
   ;; 显示所有 buffer 。
   ("C-c t g" . centaur-tabs-group-buffer-groups))
  :config
  (centaur-tabs-mode t)
  (centaur-tabs-headline-match)
  (centaur-tabs-enable-buffer-reordering)
  (centaur-tabs-group-by-projectile-project)
  (defun centaur-tabs-hide-tab (x)
    (let ((name (format "%s" x)))
      (or
       (window-dedicated-p (selected-window))
       ;; 不显示以 * 开头的 buffer 。
       (string-prefix-p "*" name)
       (and (string-prefix-p "magit" name)
            (not (file-name-extension name)))))))

;; 显示光标位置。
(use-package beacon
  :config
  ;; 翻页时不高亮位置。
  (setq beacon-blink-when-window-scrolls nil)
  (setq beacon-blink-duration 0.3)
  (beacon-mode 1))

;; 切换透明背景。
(defun my/toggle-transparency ()
  (interactive)
  (set-frame-parameter (selected-frame) 'alpha '(90 . 90))
  (add-to-list 'default-frame-alist '(alpha . (100 . 100))))

;; 在 frame 底部显示窗口。
(setq display-buffer-alist
      `((,(rx bos (or "*Apropos*" "*Help*" "*helpful" "*info*" "*Summary*" "*lsp-help*" "*vterm") (0+ not-newline))
         (display-buffer-reuse-mode-window display-buffer-below-selected)
         (window-height . 0.33)
         (mode apropos-mode help-mode helpful-mode Info-mode Man-mode))))

(use-package cnfonts
  :demand
  :init
  ;; 中英文均使用 Sarasa Term SC 字体。
  (setq cnfonts-personal-fontnames '(("Sarasa Term SC") ("Sarasa Term SC") ("HanaMinB")))
  ;; 允许字体缩放(部分主题如 lenven 依赖) 。
  (setq cnfonts-use-face-font-rescale t)
  :config
  ;; emoji 和 symbol 字体, 必须通过 cnfonts-set-font-finish-hook 调用才会生效。
  (defun my/set-fonts (&optional font)
    (setq use-default-font-for-symbols nil)
    (set-fontset-font t '(#x1f000 . #x1faff) (font-spec :family "Apple Color Emoji"))
    (set-fontset-font t 'symbol (font-spec :family "Apple Symbols" :size 20)))
  (add-hook 'cnfonts-set-font-finish-hook 'my/set-fonts)
  (cnfonts-enable))

(use-package all-the-icons
  :demand
  :after (cnfonts))

(use-package all-the-icons-ibuffer
  :init (all-the-icons-ibuffer-mode 1))

(use-package all-the-icons-completion
  :config
  (all-the-icons-completion-mode)
  (add-hook 'marginalia-mode-hook #'all-the-icons-completion-marginalia-setup))

;; fire-code-mode 只能在 GUI 模式下使用。
(when (display-graphic-p)
  (use-package fira-code-mode
    :custom
    (fira-code-mode-disabled-ligatures '("[]" "#{" "#(" "#_" "#_(" "x"))
    :hook prog-mode))

(use-package vertico
  :demand
  :straight (:repo "minad/vertico" :files ("*" "extensions/*.el" (:exclude ".git")))
  :bind
  (:map vertico-map
        ;; 在多个 source 中切换(如 consult-buffer, consult-grep) 。
        ("C-M-n" . vertico-next-group)
        ("C-M-p" . vertico-previous-group)
        ;; 快速插入。
        ("M-i" . vertico-quick-insert)
        ("M-e" . vertico-quick-exit)
        ;; 切换显示风格。
        ("M-V" . vertico-multiform-vertical)
        ("M-G" . vertico-multiform-grid)
        ("M-F" . vertico-multiform-flat)
        ("M-R" . vertico-multiform-reverse)
        ("M-U" . vertico-multiform-unobtrusive)
        ;; 文件路径操作。
        ("<backspace>" . vertico-directory-delete-char)
        ("C-w" . vertico-directory-delete-word)
        ("C-<backspace>" . vertico-directory-delete-word)
        ("RET" . vertico-directory-enter))
  :hook
  (
   ;; 在输入时清理文件路径。
   (rfn-eshadow-update-overlay . vertico-directory-tidy)
   ;; 确保 vertico 状态被保存（用于支持 vertico-repeat)。
   (minibuffer-setup . vertico-repeat-save))
  :config
  (setq vertico-count 15)
  (setq vertico-cycle nil)
  (vertico-mode 1)

  ;; 重复上一次 vertico sesson;
  (global-set-key "\M-r" #'vertico-repeat)

  ;; 开启 vertico-mouse 。
  (vertico-mouse-mode)

  ;; 开启 vertico-multiform, 为 commands 或 categories 设置不同的显示风格 。
  (vertico-multiform-mode)

  ;; 设置命令显示风格。
  (setq vertico-multiform-commands
        ;; 参数是 vertico-<name>-mode 中的 <name>, 可以多个联合使用 。
        ;; 在单独 buffer 中显示结果 consult-imenu 结果。
        '((consult-imenu buffer)
          (consult-line buffer)
          (consult-find buffer)))

  ;; 按照 completion category 设置显示风格, 优先级比 vertico-multiform-commands 低。
  ;; 为 file 设置 grid 模式, 为 grep 设置 buffer 模式.
  (setq vertico-multiform-categories
        '((file grid)
          (consult-grep buffer))))

(use-package emacs
  :init
  ;; 在 minibuffer 中不显示光标。
  (setq minibuffer-prompt-properties '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  (setq read-extended-command-predicate   #'command-completion-default-include-p)

  ;; 开启 minibuffer 递归编辑。
  (setq enable-recursive-minibuffers t))

(use-package orderless
  :demand
  :config
  (defvar +orderless-dispatch-alist
    '((?% . char-fold-to-regexp)
      (?! . orderless-without-literal)
      (?`. orderless-initialism)
      (?= . orderless-literal)
      (?~ . orderless-flex)))

  (defun +orderless-dispatch (pattern index _total)
    (cond
     ((string-suffix-p "$" pattern)
      `(orderless-regexp . ,(concat (substring pattern 0 -1) "[\x100000-\x10FFFD]*$")))
     ;; 文件扩展。
     ((and
       ;; 补全文件名或 eshell.
       (or minibuffer-completing-file-name
           (derived-mode-p 'eshell-mode))
       ;; 文件名扩展
       (string-match-p "\\`\\.." pattern))
      `(orderless-regexp . ,(concat "\\." (substring pattern 1) "[\x100000-\x10FFFD]*$")))
     ;; 忽略单个 !
     ((string= "!" pattern) `(orderless-literal . ""))
     ;; 前缀和后缀。
     ((if-let (x (assq (aref pattern 0) +orderless-dispatch-alist))
          (cons (cdr x) (substring pattern 1))
        (when-let (x (assq (aref pattern (1- (length pattern))) +orderless-dispatch-alist))
          (cons (cdr x) (substring pattern 0 -1)))))))

  ;; 自定义 orderless 风格。
  (orderless-define-completion-style +orderless-with-initialism
    (orderless-matching-styles '(orderless-initialism orderless-literal orderless-regexp)))

  (setq completion-styles '(orderless)
        completion-category-defaults nil
        completion-category-overrides '((buffer (styles basic partial-completion))
                                        (file (styles basic partial-completion))
                                        (command (styles +orderless-with-initialism))
                                        (variable (styles +orderless-with-initialism))
                                        (symbol (styles +orderless-with-initialism)))
        ;; 使用 SPACE 来分割过滤字符串, SPACE 可以用 \ 转义。
        orderless-component-separator #'orderless-escapable-split-on-space
        orderless-style-dispatchers '(+orderless-dispatch)))

(use-package consult
  :ensure-system-package (rg . ripgrep)
  :demand
  :bind
  (;; C-c 绑定 (mode-specific-map)
   ("C-c h" . consult-history)
   ("C-c m" . consult-mode-command)
   ;; C-x 绑定 (ctl-x-map)
   ("C-x M-:" . consult-complex-command)
   ("C-x b" . consult-buffer)
   ("C-x 4 b" . consult-buffer-other-window)
   ("C-x 5 b" . consult-buffer-other-frame)
   ("C-x r b" . consult-bookmark)
   ;; 寄存器绑定。
   ("M-#" . consult-register-load)
   ("M-'" . consult-register-store)
   ("C-M-#" . consult-register)
   ;; 其它自定义绑定。
   ("M-y" . consult-yank-pop)
   ("<help> a" . consult-apropos)
   ;; M-g 绑定 (goto-map)
   ("M-g e" . consult-compile-error)
   ("M-g f" . consult-flycheck)
   ("M-g g" . consult-goto-line)
   ("M-g M-g" . consult-goto-line)
   ("M-g o" . consult-outline)
   ("M-g m" . consult-mark)
   ("M-g k" . consult-global-mark)
   ("M-g i" . consult-imenu)
   ("M-g I" . consult-imenu)
   ;; M-s 绑定 (search-map)
   ("M-s d" . consult-find)
   ("M-s D" . consult-locate)
   ("M-s g" . consult-grep)
   ("M-s G" . consult-git-grep)
   ("M-s r" . consult-ripgrep)
   ("M-s l" . consult-line)
   ("M-s L" . consult-line-multi)
   ("M-s m" . consult-multi-occur)
   ("M-s k" . consult-keep-lines)
   ("M-s u" . consult-focus-lines)
   ;; Isearch 集成。
   ("M-s e" . consult-isearch-history)
   :map isearch-mode-map
   ("M-e" . consult-isearch-history)
   ("M-s e" . consult-isearch-history)
   ("M-s l" . consult-line)
   ("M-s L" . consult-line-multi)
   ;; Minibuffer 历史。
   :map minibuffer-local-map
   ("M-s" . consult-history)
   ("M-r" . consult-history))
  :hook
  (completion-list-mode . consult-preview-at-point-mode)
  :init
  ;; 如果搜索字符少于 3，可以添加后缀#开始搜索，如 #gr#。
  (setq consult-async-min-input 3)
  (setq consult-async-input-debounce 0.4)
  (setq consult-async-input-throttle 0.5)
  ;; 预览寄存器。
  (setq register-preview-delay 0.2)
  (setq register-preview-function #'consult-register-format)
  (advice-add #'register-preview :override #'consult-register-window)

  ;; 支持使用 Enter 来选择、反选候选项（例如 consult-multi-occur 场景）
  (advice-add #'completing-read-multiple :override #'consult-completing-read-multiple)

  (setq xref-show-xrefs-function #'consult-xref)
  (setq xref-show-definitions-function #'consult-xref)
  :config
  ;; 按 C-l 激活预览，否则 buffer 列表中有大文件或远程文件时会卡住。
  (setq consult-preview-key (kbd "C-l"))
  (setq consult-narrow-key "<")
  (define-key consult-narrow-map (vconcat consult-narrow-key "?") #'consult-narrow-help)

  (autoload 'projectile-project-root "projectile")
  (setq consult-project-function 'projectile-project-root)

  ;; 多选时按键绑定。
  ;; TAB - Select/deselect, RET - 提交和退出。
  (define-key consult-crm-map "\r" #'+vertico-crm-exit)
  (define-key consult-crm-map "\t" #'vertico-exit)
  (defun +vertico-crm-exit ()
    (interactive)
    (run-at-time 0 nil #'vertico-exit)
    (funcall #'vertico-exit))

  ;; 不对 consult-line 结果进行排序（按行号排序）。
  (consult-customize
   consult-line :prompt "Search: " :sort nil))

;; 选择 buffer: b, 选择 project: p, 选择文件：f 。
(use-package consult-projectile
  :straight (consult-projectile :type git :host gitlab :repo "OlMon/consult-projectile" :branch "master")
  :bind
  ("C-x p p" . consult-projectile))

(use-package consult-dir
  :bind
  (("C-x C-d" . consult-dir)
   :map minibuffer-local-completion-map
   ("C-x C-d" . consult-dir)
   ("C-x C-j" . consult-dir-jump-file)))

(use-package marginalia
  :init
  ;; 显示绝对时间。
  (setq marginalia-max-relative-age 0)
  (marginalia-mode)
  ;;:config
  ;; 不给 file 加注释，防止 TRAMP 变慢。
  ;; (setq marginalia-annotator-registry
  ;;       (assq-delete-all 'file marginalia-annotator-registry))
  ;; (setq marginalia-annotator-registry
  ;;       (assq-delete-all 'project-file marginalia-annotator-registry))
  )

(use-package embark
  :init
  (setq prefix-help-command #'embark-prefix-help-command)
  :config
  (setq embark-prompter 'embark-keymap-prompter)
  (setq embark-collect-live-update-delay 0.5)
  (setq embark-collect-live-initial-delay 0.8)
  ;; 隐藏 Embark live/completions buffers 的 modeline.
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none))))
  :bind
  (("C-;" . embark-act)
   ("C-h B" . embark-bindings)))

(use-package embark-consult
  :after (embark consult)
  :demand
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package corfu
  :demand
  :straight '(corfu :host github :repo "minad/corfu")
  :custom
  ;; 开启自动补全。
  (corfu-auto t)
  (corfu-auto-prefix 2)
  (corfu-auto-delay 0.25)
  (corfu-min-width 80)
  (corfu-max-width corfu-min-width)
  (corfu-count 14)
  (corfu-scroll-margin 4)
  ;; 后续使用 corfu-doc 来显示文档，故关闭。
  (corfu-echo-documentation nil)
  :config
  (corfu-global-mode))

;; 总是在弹出菜单中显示候选者。
(setq completion-cycle-threshold nil)

;; 使用 TAB 来 indentation+completion(completion-at-point 默认是 M-TAB) 。
(setq tab-always-indent 'complete)
(setq c-tab-always-indent 'complete)

;; 在候选者右方显示文档。
(use-package corfu-doc
  :straight '(corfu-doc :host github :repo "galeo/corfu-doc")
  :after (corfu)
  :hook (corfu-mode . corfu-doc-mode)
  :bind
  (:map corfu-map
        ("M-n" . corfu-doc-sroll-up)
        ("M-p" . corfu-doc-scroll-down))
  :custom
  (corfu-doc-delay 0.3)
  (corfu-doc-max-width 70)
  (corfu-doc-max-height 20))

(use-package cape
  :demand
  :straight '(cape :host github :repo "minad/cape")
  :init
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-keyword)
  ;; Complete word from current buffers
  ;;(add-to-list 'completion-at-point-functions #'cape-dabbrev)
  ;; Complete Elisp symbol
  (add-to-list 'completion-at-point-functions #'cape-symbol)
  ;; Complete abbreviation
  ;;(add-to-list 'completion-at-point-functions #'cape-abbrev)
  ;;(add-to-list 'completion-at-point-functions #'cape-ispell)
  ;; Complete word from dictionary file
  ;;(add-to-list 'completion-at-point-functions #'cape-dict)
  ;; Complete entire line from file
  ;;(add-to-list 'completion-at-point-functions #'cape-line)
  :config
  (setq cape-dabbrev-min-length 3))

(use-package kind-icon
  :straight '(kind-icon :host github :repo "jdtsmith/kind-icon")
  :after corfu
  :demand
  :custom
  (kind-icon-default-face 'corfu-default)
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(use-package yasnippet
  :demand
  :init
  (defvar snippet-directory "~/.emacs.d/snippets")
  (if (not (file-exists-p snippet-directory))
      (make-directory snippet-directory t))
  :commands yas-minor-mode
  :hook
  ((prog-mode org-mode  vterm-mode) . yas-minor-mode)
  :config
  (add-to-list 'yas-snippet-dirs snippet-directory)
  (yas-global-mode 1))

(use-package yasnippet-snippets :demand)

(use-package yasnippet-classic-snippets :demand)

(use-package consult-yasnippet
  :demand
  :after(consult yasnippet)
  :bind
  (:map yas-minor-mode-map
        ("C-c y" . 'consult-yasnippet)))

(use-package goto-chg
  :config
  (global-set-key (kbd "C->") 'goto-last-change)
  (global-set-key (kbd "C-<") 'goto-last-change-reverse))

(use-package avy
  :config
  ;; 值在当前 window 中跳转。
  (setq avy-all-windows nil)
  (setq avy-background t)
  :bind
  ("M-g c" . avy-goto-char-2)
  ("M-g l" . avy-goto-line))

(use-package ace-window
  :init
  ;; 使用字母而非数字标记窗口，便于跳转。
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  :config
  ;; 设置为 frame 后会忽略 treemacs frame，否则即使两个窗口时也会提示选择。
  (setq aw-scope 'frame)
  ;; 总是提示窗口选择，进而执行 ace 命令。
  (setq aw-dispatch-always t)
  (global-set-key (kbd "M-o") 'ace-window)
  ;; 在窗口左上角显示位置字符。
  (setq aw-char-position 'top-left)
  ;; 调大窗口选择字符。
  (custom-set-faces
   '(aw-leading-char-face
     ((t (:inherit ace-jump-face-foreground :foreground "red" :height 1.5))))))

(use-package rime
  :ensure-system-package ("/Applications/SwitchKey.app" . "brew install --cask switchkey")
  :custom
  (rime-user-data-dir "~/Library/Rime/")
  (rime-librime-root "~/.emacs.d/librime/dist")
  (rime-emacs-module-header-root "/usr/local/Cellar/emacs-plus@28/28.0.50/include")
  :bind
  ( :map rime-active-mode-map
    ;; 强制切换到英文模式，直到按回车
    ("M-j" . 'rime-inline-ascii)
    :map rime-mode-map
    ;; 中英文切换
    ("C-=" . 'rime-send-keybinding)
    ;; 输入法菜单
    ("C-+" . 'rime-send-keybinding)
    ;; 中英文标点切换
    ("C-." . 'rime-send-keybinding)
    ;; 全半角切换
    ("C-," . 'rime-send-keybinding)
    ;; 强制切换到中文模式
    ("M-j" . 'rime-force-enable))
  :config
  ;; 在 modline 高亮输入法图标, 可用来快速分辨分中英文输入状态。
  (setq mode-line-mule-info '((:eval (rime-lighter))))
  ;; support shift-l, shift-r, control-l, control-r, 只有当使用系统 RIME 输入法时才有效。
  (setq rime-inline-ascii-trigger 'shift-l)
  ;; 临时英文模式。
  (setq rime-disable-predicates
        '(rime-predicate-ace-window-p
          rime-predicate-hydra-p
          rime-predicate-current-uppercase-letter-p
          rime-predicate-after-alphabet-char-p
          rime-predicate-space-after-cc-p
          rime-predicate-prog-in-code-p
          rime-predicate-after-ascii-char-p))
  (setq rime-posframe-properties (list :font "Sarasa Gothic SC" :internal-border-width 2))
  (setq rime-show-candidate 'posframe))

;; 切换到 vterm-mode 类型外的 buffer 时激活 RIME 输入法。
(defadvice switch-to-buffer (after activate-input-method activate)
  (if (string-match "vterm-mode" (symbol-name major-mode))
      (activate-input-method nil)
    (activate-input-method "rime")))

;; Emacs will automatically set default-input-method to rfc1345 if locale is
;; UTF-8. https://github.com/purcell/emacs.d/issues/320
(add-hook 'emacs-startup-hook (lambda () (setq default-input-method "rime")))

(use-package org
  :straight (org :repo "https://git.savannah.gnu.org/git/emacs/org-mode.git")
  :ensure auctex
  :demand
  :ensure-system-package
  ((watchexec . watchexec)
   (pygmentize . pygments)
   (magick . imagemagick))
  :config
  (setq org-ellipsis ".."
        org-highlight-latex-and-related '(latex)
        org-hide-emphasis-markers t
        ;; 去掉 * 和 /, 使它们不再具有强调含义。
        org-emphasis-alist
        '(("_" underline)
         ("=" org-verbatim verbatim)
         ("~" org-code verbatim)
         ("+" (:strike-through t)))
        ;; 隐藏 block
        org-hide-block-startup t
        org-hidden-keywords '(title)
        org-cycle-separator-lines 2
        org-cycle-level-faces t
        org-n-level-faces 4
        org-tags-column -80
        org-log-into-drawer t
        org-log-done 'note
        ;; 先从 #+ATTR.* 获取宽度，如果没有设置则默认为 300 。
        org-image-actual-width '(300)
        org-export-with-broken-links t
        org-startup-folded 'content
        ;; 使用 R_{s} 形式的下标（默认是 R_s, 容易与正常内容混淆) 。
        org-use-sub-superscripts nil
        ;; export 时不处理 super/subscripting, 等效于 #+OPTIONS: ^:nil 。
        org-export-with-sub-superscripts nil
        org-startup-indented t
        ;; 文件链接使用相对路径, 解决 hugo 等 image 引用的问题。
        org-link-file-path-type 'relative)
  (setq org-catch-invisible-edits 'show)
  (setq org-todo-keywords
        '((sequence "☞ TODO(t)" "PROJ(p)" "⚔ INPROCESS(s)" "⚑ WAITING(w)"
                    "|" "☟ NEXT(n)" "✰ Important(i)" "✔ DONE(d)" "✘ CANCELED(c@)")
          (sequence "✍ NOTE(N)" "FIXME(f)" "☕ BREAK(b)" "❤ Love(l)" "REVIEW(r)" )))

  (global-set-key (kbd "C-c l") 'org-store-link)
  (global-set-key (kbd "C-c a") 'org-agenda)
  (global-set-key (kbd "C-c c") 'org-capture)
  (global-set-key (kbd "C-c b") 'org-switchb)
  (add-hook 'org-mode-hook 'turn-on-auto-fill)
  (add-hook 'org-mode-hook (lambda () (display-line-numbers-mode 0))))

;; 自动创建和更新目录。
(use-package org-make-toc
  :config
  (add-hook 'org-mode-hook #'org-make-toc-mode))

(use-package htmlize)

(setq org-html-doctype "html5")
(setq org-html-html5-fancy t)
(setq org-html-self-link-headlines t)
(setq org-html-preamble "<a name=\"top\" id=\"top\"></a>")

(use-package org-html-themify
  :straight (org-html-themify :repo "DogLooksGood/org-html-themify" :files ("*.el" "*.js" "*.css"))
  :hook
  (org-mode . org-html-themify-mode)
  :custom
  (org-html-themify-themes '((dark . doom-palenight) (light . doom-one-light))))

(defun my/org-faces ()
  (setq-default line-spacing 1)
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :weight 'medium :height (cdr face)))
  ;; 美化 BEGIN_SRC 整行。
  (setq org-fontify-whole-block-delimiter-line t)
  (custom-theme-set-faces
   'user
   '(org-block ((t (:font "Sarasa Term SC-15" :inherit fixed-pitch))))
   ;; 调小高度 , 并设置下划线。
   '(org-block-begin-line ((t (:height 0.8 :underline "#A7A6AA"))))
   '(org-block-end-line ((t (:height 0.8 :underline "#A7A6AA"))))
   '(org-document-title ((t (:foreground "#ffb86c" :weight bold :height 1.5))))
   '(org-document-info ((t (:height 0.8))))
   '(org-document-info-keyword ((t (:height 0.8))))
   '(org-link ((t (:foreground "royal blue" :underline t))))
   '(org-meta-line ((t ( :height 0.8))))
   '(org-property-value ((t (:height 0.8))) t)
   '(org-drawer ((t (:height 0.8))) t)
   '(org-special-keyword ((t (:height 0.8))))
   ;;'(org-table ((t (:foreground "#83a598"))))
   '(org-tag ((t (:weight bold :height 0.8))))
   ;;'(org-ellipsis ((t (:foreground nil))))
   )
  (setq-default prettify-symbols-alist '(("#+BEGIN_SRC" . "»")
                                         ("#+END_SRC" . "«")
                                         ("#+begin_src" . "»")
                                         ("#+end_src" . "«")))
  (setq prettify-symbols-unprettify-at-point 'right-edge))
(add-hook 'org-mode-hook 'my/org-faces)
(add-hook 'org-mode-hook 'prettify-symbols-mode)

(use-package org-superstar
  :after (org)
  :hook
  (org-mode . org-superstar-mode)
  :custom
  (org-superstar-remove-leading-stars t)
  (org-superstar-headline-bullets-list '("✖" "✚" "◉" "○" "▶"))
  ;; (org-superstar-headline-bullets-list '("◉" "○" "●" "○" "●" "○" "●"))
  )

(use-package org-fancy-priorities
  :after (org)
  :hook
  (org-mode . org-fancy-priorities-mode)
  :config
  (setq org-fancy-priorities-list '("[A]" "[B]" "[C]")))

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
  :demand
  :after (org)
  :hook
  (org-mode . (lambda () (my/org-mode-visual-fill 110 130)))
  :config
  ;; 文字缩放时自动调整 visual-fill-column-width 。
  (advice-add 'text-scale-adjust :after #'visual-fill-column-adjust))

(setq org-agenda-time-grid
      (quote ((daily today require-timed)
              (300 600 900 1200 1500 1800 2100 2400)
              "......"
              "-----------------------------------------------------"
              )))

;; org-agenda 展示的文件。
(setq org-agenda-files
      '("~/docs/orgs/gtd.org"
        "~/docs/orgs/capture.org"))
(setq org-agenda-start-day "-7d")
(setq org-agenda-span 21)
(setq org-agenda-include-diary t)
;; use org-journal
;;(setq diary-file "~/docs/orgs/diary")
;;(setq diary-mail-addr "geekard@qq.com")
;; 获取经纬度：https://www.latlong.net/
(setq calendar-latitude +39.904202)
(setq calendar-longitude +116.407394)
(setq calendar-location-name "北京")
(setq calendar-remove-frame-by-deleting t)
;; 每周第一天是周一。
(setq calendar-week-start-day 1)
;; 标记有记录的日期。
(setq mark-diary-entries-in-calendar t)
;; 标记节假日。
(setq mark-holidays-in-calendar nil)
;; 不显示节日列表。
(setq view-calendar-holidays-initially nil)
(setq org-agenda-include-diary t)

;; 除去基督徒、希伯来和伊斯兰教的节日。
(setq christian-holidays nil
      hebrew-holidays nil
      islamic-holidays nil
      solar-holidays nil
      bahai-holidays nil)

(setq mark-diary-entries-in-calendar t
      appt-issue-message nil
      mark-holidays-in-calendar t
      view-calendar-holidays-initially nil)

(setq diary-date-forms '((year "/" month "/" day "[^/0-9]"))
      calendar-date-display-form '(year "/" month "/" day)
      calendar-time-display-form '(24-hours ":" minutes (if time-zone " (") time-zone (if time-zone ")")))

(add-hook 'today-visible-calendar-hook 'calendar-mark-today)

(autoload 'chinese-year "cal-china" "Chinese year data" t)

(setq calendar-load-hook '(lambda ()
                            (set-face-foreground 'diary-face   "skyblue")
                            (set-face-background 'holiday-face "slate blue")
                            (set-face-foreground 'holiday-face "white")))

(use-package org-super-agenda)

;; refile 的位置是 agenda 文件的前三层 headline 。
(setq org-refile-targets '((org-agenda-files :maxlevel . 3)))
;; 使用文件路径的形式显示 filename 和 headline, 方便在文件的 top-head 添加内容。
(setq org-refile-use-outline-path 'file)
;; 必须设置为 nil 才能显示 headline, 否则只显示文件名 。
(setq org-outline-path-complete-in-steps nil)
;; 支持为 subtree 在 refile target 文件指定一个新的父节点 。
(setq org-refile-allow-creating-parent-nodes 'confirm)

(require 'org-protocol)
(require 'org-capture)

(setq org-capture-templates
      '(("c" "Capture" entry (file+headline "~/docs/orgs/capture.org" "Capture")
         "* %^{Title}\nDate: %U\nSource: %:annotation\n\n%:initial" :empty-lines 1)
        ("t" "Todo" entry (file+headline "~/docs/orgs/gtd.org" "Tasks")
         "* TODO %?\n %U %a\n %i" :empty-lines 1)))

(use-package org-download
  :ensure-system-package pngpaste
  :bind
  ("<f6>" . org-download-screenshot)
  :config
  (setq-default org-download-image-dir "./images/")
  (setq org-download-method 'directory
        org-download-display-inline-images 'posframe
        org-download-screenshot-method "pngpaste %s"
        org-download-image-attr-list '("#+ATTR_HTML: :width 400 :align center"))
  (add-hook 'dired-mode-hook 'org-download-enable)
  (org-download-enable))

(setq org-confirm-babel-evaluate nil)
(setq org-src-fontify-natively t)
(setq org-src-tab-acts-natively t)
;; 为 #+begin_quote 和  #+begin_verse 添加特殊 face 。
(setq org-fontify-quote-and-verse-blocks t)
;; 不自动缩进。
(setq org-src-preserve-indentation t)
(setq org-edit-src-content-indentation 0)
;; 在当前窗口编辑 SRC Block.
(setq org-src-window-setup 'current-window)

(require 'org)
(use-package ob-go)
(use-package ox-reveal)
(use-package ox-gfm)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((shell . t)
   (js . t)
   (go . t)
   (emacs-lisp . t)
   (python . t)
   (dot . t)
   (css . t)))

(use-package org-contrib
  :straight (org-contrib :repo "https://git.sr.ht/~bzg/org-contrib")
  :demand)

(use-package emacs
  :straight (:type built-in)
  :ensure-system-package terminal-notifier)

(defvar terminal-notifier-command (executable-find "terminal-notifier") "The path to terminal-notifier.")
(defun terminal-notifier-notify (title message)
  (start-process "terminal-notifier"
                 "terminal-notifier"
                 terminal-notifier-command
                 "-title" title
                 "-sound" "default"
                 "-message" message
                 "-activate" "org.gnu.Emacs"))

(defun timed-notification (time msg)
  (interactive "sNotification when (e.g: 2 minutes, 60 seconds, 3 days): \nsMessage: ")
  (run-at-time time nil (lambda (msg) (terminal-notifier-notify "Emacs" msg)) msg))

;;(terminal-notifier-notify "Emacs notification" "Something amusing happened")
(setq org-show-notification-handler (lambda (msg) (timed-notification nil msg)))

(require 'ox-latex)
(with-eval-after-load 'ox-latex
  ;; latex image 的默认宽度, 可以通过 #+ATTR_LATEX :width xx 配置。
  (setq org-latex-image-default-width "0.7\\linewidth")
  ;; 默认使用 booktabs 来格式化表格。
  (setq org-latex-tables-booktabs t)
  ;; 保存 LaTeX 日志文件。
  (setq org-latex-remove-logfiles nil)
  (setq org-latex-pdf-process '("latexmk -xelatex -quiet -shell-escape -f %f"))
  ;; ;; Alist of packages to be inserted in every LaTeX header.
  ;; (setq org-latex-packages-alist
  ;;       (quote (("" "color" t)
  ;;               ("" "xcolor" t)
  ;;               ("" "listings" t)
  ;;               ("" "fontspec" t)
  ;;               ("" "parskip" t) ;; 增加正文段落的间距
  ;;               ("AUTO" "inputenc" t))))
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
                 ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))
  ;; 自定义 latex 语言环境(基于 tcolorbox), 参考：https://blog.shimanoke.com/ja/posts/output-latex-code-with-tcolorbox/
  (setq org-latex-custom-lang-environments
        '((c "\\begin{programlist}[label={%l}]{c}{: %c}\n%s\\end{programlist}")
          (ditaa "\\begin{programlist}[label={%l}]{text}{: %c}\n%s\\end{programlist}")
          (emacs-lisp "\\begin{programlist}[label={%l}]{lisp}{: %c}\n%s\\end{programlist}")
          (ruby "\\begin{programlist}[label={%l}]{ruby}{: %c}\n%s\\end{programlist}")
          (latex "\\begin{programlist}[label={%l}]{latex}{: %c}\n%s\\end{programlist}")
          (go "\\begin{programlist}[label={%l}]{go}{: %c}\n%s\\end{programlist}")
          (lua "\\begin{programlist}[label={%l}]{lua}{: %c}\n%s\\end{programlist}")
          (java "\\begin{programlist}[label={%l}]{java}{: %c}\n%s\\end{programlist}")
          (javascript "\\begin{programlist}[label={%l}]{javascript}{: %c}\n%s\\end{programlist}")
          (json "\\begin{programlist}[label={%l}]{json}{: %c}\n%s\\end{programlist}")
          (plantuml "\\begin{programlist}[label={%l}]{text}{: %c}\n%s\\end{programlist}")
          (yaml "\\begin{programlist}[label={%l}]{yaml}{: %c}\n%s\\end{programlist}")
          (maxima "\\begin{programlist}[label={%l}]{text}{: %c}\n%s\\end{programlist}")
          (ipython "\\begin{programlist}[label={%l}]{python}{: %c}\n%s\\end{programlist}")
          (python "\\begin{programlist}[label={%l}]{python}{: %c}\n%s\\end{programlist}")
          (perl "\\begin{programlist}[label={%l}]{perl}{: %c}\n%s\\end{programlist}")
          (html "\\begin{programlist}[label={%l}]{html}{: %c}\n%s\\end{programlist}")
          (org "\\begin{programlist}[label={%l}]{text}{: %c}\n%s\\end{programlist}")
          (typescript "\\begin{programlist}[label={%l}]{typescript}{: %c}\n%s\\end{programlist}")
          (scss "\\begin{programlist}[label={%l}]{scss}{: %c}\n%s\\end{programlist}")
          (sh "\\begin{programlist}[label={%l}]{shell}{: %c}\n%s\\end{programlist}")
          (shell "\\begin{programlist}[label={%l}]{shell}{: %c}\n%s\\end{programlist}")
          (shellinput "\\begin{shellinput}[%c]\n%s\\end{shellinput}")
          (shelloutput "\\begin{shelloutput}[%c]\n%s\\end{shelloutput}")))
  (setq org-latex-listings 'listings))

(use-package org-tree-slide
  :after (org)
  :commands org-tree-slide-mode
  :bind
  (:map org-mode-map
        ("<f8>" . org-tree-slide-mode)
        :map org-tree-slide-mode-map
        ("<f9>" . org-tree-slide-content)
        ("<left>" . org-tree-slide-move-previous-tree)
        ("<right>" . org-tree-slide-move-next-tree))
  :hook
  ((org-tree-slide-play . (lambda ()
                            (blink-cursor-mode -1)
                            (setq-default x-stretch-cursor -1)
                            (beacon-mode -1)
                            (redraw-display)
                            (org-display-inline-images)
                            (text-scale-increase 1)
                            (centaur-tabs-mode 0)
                            (read-only-mode 1)))
   (org-tree-slide-stop . (lambda ()
                            (blink-cursor-mode +1)
                            (setq-default x-stretch-cursor t)
                            (text-scale-increase 0)
                            (beacon-mode +1)
                            (centaur-tabs-mode 1)
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
  (add-hook 'org-tree-slide-play-hook #'+org-present-hide-blocks-h))

;; 设置缺省 prefix key, 必须在加载 org-journal 前设置。
(setq org-journal-prefix-key "C-c j")

(use-package org-journal
  :demand
  :commands org-journal-new-entry
  :init
  (defun org-journal-save-entry-and-exit()
    (interactive)
    (save-buffer)
    (kill-buffer-and-window))
  :bind
  (:map org-journal-mode-map
        ("C-c C-j" . 'org-journal-new-entry)
        ("C-c C-e" . 'org-journal-save-entry-and-exit))
  :config
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
  (setq org-journal-file-header 'org-journal-file-header-func)

  ;; org-agenda 集成。
  ;; automatically adds the current and all future journal entries to the agenda
  ;;(setq org-journal-enable-agenda-integration t)
  ;; When org-journal-file-pattern has the default value, this would be the regex.
  (setq org-agenda-file-regexp "\\`\\\([^.].*\\.org\\\|[0-9]\\\{8\\\}\\\(\\.gpg\\\)?\\\)\\'")
  (add-to-list 'org-agenda-files org-journal-dir)

  ;; org-capture 集成。
  (defun org-journal-find-location ()
    (org-journal-new-entry t)
    (unless (eq org-journal-file-type 'daily)
      (org-narrow-to-subtree))
    (goto-char (point-max)))
  (setq org-capture-templates
        (cons '("j" "Journal" plain (function org-journal-find-location)
                "** %(format-time-string org-journal-time-format)%^{Title}\n%i%?"
                :jump-to-captured t :immediate-finish t) org-capture-templates)))

(use-package elfeed
  :demand
  :config
  (setq elfeed-db-directory (expand-file-name "elfeed" user-emacs-directory))
  (setq elfeed-show-entry-switch 'display-buffer)
  (setq elfeed-curl-timeout 30)
  (setf url-queue-timeout 40)
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

(setq vc-follow-symlinks t)

(use-package magit
  :custom
  ;; 在当前 window 中显示 magit buffer.
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  (magit-commit-ask-to-stage nil)
  ;; 默认不选中 magit buffer.
  (magit-display-buffer-noselect t)
  (magit-log-arguments '("--graph" "--decorate" "--color"))
  :config
  ;; kill 所有 magit buffer.
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
  (setq magit-bury-buffer-function #'my-magit-kill-buffers))

(use-package git-link
  :config
  (global-set-key (kbd "C-c g l") 'git-link)
  (setq git-link-use-commit t))

;; diff 时显示空白字符。
(defun my/diff-spaces ()
  (setq-local whitespace-style
              '(face
                tabs
                tab-mark
                spaces
                space-mark
                trailing
                indentation::space
                indentation::tab
                newline
                newline-mark))
  (whitespace-mode 1))

(use-package diff-mode
  :straight (:type built-in)
  :init
  (setq diff-default-read-only t)
  (setq diff-advance-after-apply-hunk t)
  (setq diff-update-on-the-fly t)
  (setq diff-refine nil)
  ;; better for patches
  (setq diff-font-lock-prettify nil)
  :config
  (add-hook 'diff-mode-hook 'my/diff-spaces))

(use-package ediff
  :straight (:type built-in)
  :config
  (setq ediff-keep-variants nil)
  ;; 忽略空格
  (setq ediff-diff-options "-w")
  (setq ediff-split-window-function 'split-window-horizontally)
  ;; 不创建新的 frame 来显示 Control-Panel
  (setq ediff-window-setup-function #'ediff-setup-windows-plain)
  (add-hook 'ediff-mode-hook 'my/diff-spaces)
  ;; 启动 ediff 前关闭 treemacs frame, 否则 Control-Panel 显示异常
  (add-hook 'ediff-before-setup-hook
            (lambda ()
              (require 'treemacs)
              (if (string-match "visible" (symbol-name (treemacs-current-visibility)))
                  (delete-window (treemacs-get-local-window)) ) ))

  ;; ediff 时自动展开 org-mode, https://dotemacs.readthedocs.io/en/latest/#ediff
  (defun f-ediff-org-showhide (buf command &rest cmdargs)
    "If buffer exists and is orgmode then execute command"
    (when buf
      (when (eq (buffer-local-value 'major-mode (get-buffer buf)) 'org-mode)
        (save-excursion (set-buffer buf) (apply command cmdargs)))))

  (defun f-ediff-org-unfold-tree-element ()
    "Unfold tree at diff location"
    (f-ediff-org-showhide ediff-buffer-A 'org-reveal)
    (f-ediff-org-showhide ediff-buffer-B 'org-reveal)
    (f-ediff-org-showhide ediff-buffer-C 'org-reveal))

  (defun f-ediff-org-fold-tree ()
    "Fold tree back to top level"
    (f-ediff-org-showhide ediff-buffer-A 'hide-sublevels 1)
    (f-ediff-org-showhide ediff-buffer-B 'hide-sublevels 1)
    (f-ediff-org-showhide ediff-buffer-C 'hide-sublevels 1))

  (add-hook 'ediff-select-hook 'f-ediff-org-unfold-tree-element)
  (add-hook 'ediff-unselect-hook 'f-ediff-org-fold-tree))

(use-package flycheck
  :demand
  :config
  ;; 高亮出现错误的列位置。
  (setq flycheck-highlighting-mode (quote columns))
  (setq flycheck-check-syntax-automatically '(save idle-change mode-enabled))
  (define-key flycheck-mode-map (kbd "M-g n") #'flycheck-next-error)
  (define-key flycheck-mode-map (kbd "M-g p") #'flycheck-previous-error)
  :hook
  (prog-mode . flycheck-mode))

;; 在线显示 flycheck 错误。
(use-package flycheck-pos-tip
  :after (flycheck)
  :config
  (flycheck-pos-tip-mode))

;; flycheck 实时预览。
(use-package consult-flycheck
  :after (consult flycheck)
  :bind
  (:map flycheck-command-map ("!" . consult-flycheck)))

(use-package lsp-mode
  :after (cape orderless)
  :custom
  ;; debug 时才开启 log, 否则影响性能。
  (lsp-log-io nil)
  ;; 日志记录行数。
  (lsp-log-max 10000)
  (lsp-keymap-prefix "C-c l")
  (lsp-diagnostics-provider :flycheck)
  (lsp-diagnostics-flycheck-default-level 'warning)
  (lsp-completion-provider :none) ;; corfu.el: :none, company: :capf
  (lsp-enable-symbol-highlighting nil)
  ;; 不显示面包屑。
  (lsp-headerline-breadcrumb-enable nil)
  (lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  ;; 启用 snippet 后才支持函数或方法的 placeholder 提示。
  (lsp-enable-snippet t)
  ;; 后续使用 lsp-ui-doc 替代 eldoc, 前者还支持 mouse 和 cursor hover.
  (lsp-eldoc-enable-hover nil)
  (lsp-eldoc-render-all t)
  ;; 刷新高亮、lenses 和 links 的间隔。
  (lsp-idle-delay 0.2)
  ;; 退出最后一个 lsp buffer 时自动 kill lsp-server.
  (lsp-keep-workspace-alive nil)
  (lsp-enable-file-watchers nil)
  ;; 关闭 folding 。
  (lsp-enable-folding nil)
  ;; lsp 显示的 links 不准确且导致 treemacs 目录显示异常，故关闭。
  (lsp-enable-links nil)
  (lsp-enable-indentation nil)
  ;; flycheck 会在 modeline 展示检查结果, 故不需 lsp 再展示。
  (lsp-modeline-diagnostics-enable nil)
  ;; 不在 modeline 上显示 code-actions 信息。
  (lsp-modeline-code-actions-enable nil)
  (lsp-modeline-workspace-status-enable nil)
  (lsp-restart 'auto-restart)
  ;; 使用 projectile/project 来自动探测项目根目录。
  (lsp-auto-guess-root t)
  :init
  ;; https://github.com/minad/corfu/wiki
  (defun my/orderless-dispatch-flex-first (_pattern index _total)
    (and (eq index 0) 'orderless-flex))

  ;; 设置 lsp 使用 corfu 来进行补全。
  (defun my/lsp-mode-setup-completion ()
    (setf (alist-get 'styles (alist-get 'lsp-capf completion-category-defaults))
          '(orderless)))

  ;; Optionally configure the first word as flex filtered.
  (add-hook 'orderless-style-dispatchers #'my/orderless-dispatch-flex-first nil 'local)
  ;; Optionally configure the cape-capf-buster.
  (setq-local completion-at-point-functions (list (cape-capf-buster #'lsp-completion-at-point)))
  :hook
  ((java-mode . lsp)
   (python-mode . lsp)
   (go-mode . lsp)
   ;;(yaml-mode . lsp)
   ;;(js-mode . lsp)
   (web-mode . lsp)
   (tide-mode . lsp)
   (typescript-mode . lsp)
   (dockerfile-mode . lsp)
   (lsp-completion-mode . my/lsp-mode-setup-completion))
  :config
  (dolist (dir '("[/\\\\][^/\\\\]*\\.\\(json\\|html\\|pyc\\|class\\|log\\|jade\\|md\\)\\'"
                 "[/\\\\]resources/META-INF\\'"
                 "[/\\\\]vendor\\'"
                 "[/\\\\]node_modules\\'"
                 "[/\\\\]\\.settings\\'"
                 "[/\\\\]\\.project\\'"
                 "[/\\\\]\\.travis\\'"
                 "[/\\\\]bazel-*"
                 "[/\\\\]\\.cache"
                 "[/\\\\]\\.clwb$"))
    (push dir lsp-file-watch-ignored-directories))
  :bind
  (:map lsp-mode-map
        ("C-c f" . lsp-format-region)
        ("C-c e" . lsp-describe-thing-at-point)
        ("C-c a" . lsp-execute-code-action)
        ("C-c r" . lsp-rename)
        ([remap xref-find-definitions] . lsp-find-definition)
        ([remap xref-find-references] . lsp-find-references)))

(use-package consult-lsp
  :after (lsp-mode consult)
  :config
  (define-key lsp-mode-map [remap xref-find-apropos] #'consult-lsp-symbols))

(use-package lsp-ui
  :after (lsp-mode flycheck)
  :custom
  ;; 显示目录。
  (lsp-ui-peek-show-directory t)
  ;; 文件列表宽度。
  (lsp-ui-peek-list-width 80)
  (lsp-ui-doc-delay 0.1)
  ;;(lsp-ui-doc-position 'at-point)
  ;; 启用 flycheck 集成。
  (lsp-ui-flycheck-enable t)
  (lsp-ui-sideline-enable nil)
  (lsp-ui-peek-fontify 'always)
  :config
  (define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
  (define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references))

(use-package emacs
  :straight (:type built-in)
  :ensure-system-package
  ((pyenv . "brew install --HEAD pyenv")
   (pyenv-virtualenv . "brew install --HEAD pyenv-virtualenv")))

(defun my/python-setup-shell (&rest args)
  (if (executable-find "ipython")
      (progn
        (setq python-shell-interpreter "ipython")
        ;; ipython version >= 5
        (setq python-shell-interpreter-args "--simple-prompt -i"))
    (progn
      (setq python-shell-interpreter "python")
      (setq python-shell-interpreter-args "-i"))))

(defun my/python-setup-checkers (&rest args)
  (when (fboundp 'flycheck-set-checker-executable)
    (let ((pylint (executable-find "pylint"))
          (flake8 (executable-find "flake8")))
      (when pylint
        (flycheck-set-checker-executable "python-pylint" pylint))
      (when flake8
        (flycheck-set-checker-executable "python-flake8" flake8)))))


(use-package python
  :after (flycheck)
  :ensure-system-package
  ((pylint . pylint)
   (flake8 . flake8)
   (ipython . "pip install ipython"))
  :init
  (setq-default indent-tabs-mode nil)
  (setq-default tab-width 4)
  (setq-default python-indent-offset 4)
  (with-eval-after-load 'exec-path-from-shell (exec-path-from-shell-copy-env "PYTHONPATH"))
  :hook
  (python-mode . (lambda ()
                   (my/python-setup-shell)
                   (my/python-setup-checkers))))

(use-package lsp-pyright
  :after (python)
  :ensure-system-package
  ((pyright . "sudo npm update -g pyright")
   (yapf . "pip install yapf"))
  :init
  (defvar pyright-directory "~/.emacs.d/.cache/lsp/npm/pyright/lib")
  (if (not (file-exists-p pyright-directory))
      (make-directory pyright-directory t))
  (when (executable-find "python3")
    (setq lsp-pyright-python-executable-cmd "python3"))
  ;; 使用 yapf 格式化 python 代码。
  (defun lsp-pyright-format-buffer ()
    (interactive)
    (when (and (executable-find "yapf") buffer-file-name)
      (call-process "yapf" nil nil nil "-i" buffer-file-name)))
  :hook
  (python-mode . (lambda ()
                   (require 'lsp-pyright)
                   (add-hook 'after-save-hook #'lsp-pyright-format-buffer t t))))

(use-package go-mode
  :after (lsp-mode)
  :ensure-system-package (gopls . "go install golang.org/x/tools/gopls@latest")
  :init
  (setq godoc-at-point-function #'godoc-gogetdoc)
  (defun lsp-go-install-save-hooks ()
    (add-hook 'before-save-hook #'lsp-format-buffer t t)
    (add-hook 'before-save-hook #'lsp-organize-imports t t))
  :hook
  (go-mode . lsp-go-install-save-hooks)
  :bind
  (:map go-mode-map
        ("C-c R" . go-remove-unused-imports)
        ("<f1>" . godoc-at-point))
  :config
  ;; 配置 -mod=mod, 防止带有 vendor 目录的项目报错: go: inconsistent vendoring
  (setq lsp-go-env '((GOFLAGS . "-mod=mod")))
  (lsp-register-custom-settings
   `(("gopls.allExperiments" t t)
     ("gopls.staticcheck" t t)
     ("gopls.completeUnimported" t t)
     ;; opts a user into the experimental support for multi-module workspaces
     ("gopls.experimentalWorkspaceModule" t t)
     ;;disables -mod=readonly, allowing imports from out-of-scope module
     ("gopls.allowModfileModifications" t t)
     ;;disables GOPROXY=off, allowing implicit module downloads rather than requiring user action
     ("gopls.allowImplicitNetworkAccess" t t)
     ;; enables gopls to fall back on outdated package metadata
     ("gopls.experimentalUseInvalidMetadata" t t))))

;; 安装或更新工具。
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

;; 其它。
(use-package go-fill-struct)
(use-package go-impl)

(use-package go-tag
  :bind (:map go-mode-map
              ("C-c t a" . go-tag-add)
              ("C-c t r" . go-tag-remove))
  :init (setq go-tag-args (list "-transform" "camelcase")))

(use-package go-gen-test
  :bind (:map go-mode-map
              ("C-c t g" . go-gen-test-dwim)))

(use-package gotest
  :bind (:map go-mode-map
              ("C-c t f" . go-test-current-file)
              ("C-c t t" . go-test-current-test)
              ("C-c t j" . go-test-current-project)
              ("C-c t b" . go-test-current-benchmark)
              ("C-c t c" . go-test-current-coverage)
              ("C-c t x" . go-run)))

(use-package go-playground
  :diminish
  :commands (go-playground-mode))

(use-package flycheck-golangci-lint
  :ensure-system-package (golangci-lint)
  :after flycheck
  :defines flycheck-disabled-checkers
  :hook (go-mode . (lambda ()
                     "Enable golangci-lint."
                     (setq flycheck-disabled-checkers '(go-gofmt
                                                        go-golint
                                                        go-vet
                                                        go-build
                                                        go-test
                                                        go-staticcheck
                                                        go-errcheck))
                     (flycheck-golangci-lint-setup))))

(use-package markdown-mode
  :ensure-system-package multimarkdown
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
  :ensure-system-package
  (grip . "pip install grip")
  :bind
  (:map markdown-mode-command-map ("g" . grip-mode))
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
          grip-github-password (cadr credential))))

(use-package markdown-toc
  :after(markdown-mode)
  :bind (:map markdown-mode-command-map
              ("r" . markdown-toc-generate-or-refresh-toc)))

(use-package dockerfile-mode
  :ensure-system-package
  (docker-langserver . "npm install -g dockerfile-language-server-nodejs")
  :config
  (add-to-list 'auto-mode-alist '("Dockerfile\\'" . dockerfile-mode)))

(defun my/use-eslint-from-node-modules ()
  ;; use local eslint from node_modules before global
  ;; http://emacs.stackexchange.com/questions/21205/flycheck-with-file-relative-eslint-executable
  (let* ((root (locate-dominating-file (or (buffer-file-name) default-directory) "node_modules"))
         (eslint (and root (expand-file-name "node_modules/eslint/bin/eslint.js" root))))
    (when (and eslint (file-executable-p eslint))
      (setq-local flycheck-javascript-eslint-executable eslint))))

;; (shell-command "which npm &>/dev/null || brew install npm &>/dev/null")
(defun my/setup-tide-mode ()
  "Use hl-identifier-mode only on js or ts buffers."
  (when (and (stringp buffer-file-name)
             (string-match "\\.[tj]sx?\\'" buffer-file-name))
    (tide-setup)
    (add-hook 'flycheck-mode-hook #'my/use-eslint-from-node-modules)
    (tide-hl-identifier-mode +1)))

;; for .ts and .tsx file
(use-package typescript-mode
  :ensure-system-package
  (eslint . "npm install -g eslint babel-eslint eslint-plugin-react")
  :init
  (add-to-list 'auto-mode-alist '("\\.tsx?\\'" . typescript-mode))
  :hook
  ((typescript-mode . my/setup-tide-mode))
  :config
  (flycheck-add-mode 'typescript-tslint 'typescript-mode)
  (setq typescript-indent-level 2))

(use-package tide
  :hook ((before-save . tide-format-before-save))
  :ensure-system-package
  ((typescript-language-server . "npm install -g typescript-language-server")
  (tsc . "npm install -g typescript"))
  :config
  ;; 开启 tsserver 的 debug 日志模式。
  (setq tide-tsserver-process-environment '("TSS_LOG=-level verbose -file /tmp/tss.log")))

(use-package js2-mode
  :after (tide flycheck)
  :config
  ;; js-mode-map 将 M-. 绑定到 js-find-symbol, 没有使用 tide 和 lsp, 所以需要解
  ;; 绑。这样 M-. 被 tide 绑定到 tide-jump-to-definition.
  (define-key js-mode-map (kbd "M-.") nil)
  ;;(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
  (add-hook 'js-mode-hook 'js2-minor-mode)
  ;; 为 js/jsx 文件启动 tide.
  (add-hook 'js-mode-hook 'my/setup-tide-mode)
  ;; disable jshint since we prefer eslint checking
  (setq-default flycheck-disabled-checkers (append flycheck-disabled-checkers '(javascript-jshint)))
  (flycheck-add-mode 'javascript-eslint 'js-mode)
  (flycheck-add-next-checker 'javascript-eslint 'javascript-tide 'append)
  (flycheck-add-next-checker 'javascript-eslint 'jsx-tide 'append)
  (add-to-list 'interpreter-mode-alist '("node" . js2-mode)))

(use-package web-mode
  :after (flycheck)
  :init
  (add-to-list 'auto-mode-alist '("\\.jinja2?\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.css?\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.tmpl\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.gotmpl\\'" . web-mode))
  :custom
  (web-mode-enable-auto-pairing t)
  (web-mode-enable-css-colorization t)
  (web-mode-markup-indent-offset 4)
  (web-mode-css-indent-offset 4)
  (web-mode-code-indent-offset 4)
  (web-mode-enable-auto-quoting nil)
  (web-mode-enable-block-face t)
  (web-mode-enable-current-element-highlight t)
  :config
  (flycheck-add-mode 'javascript-eslint 'web-mode))

(defun my/json-format ()
  (interactive)
  (save-excursion
    (shell-command-on-region (mark) (point) "python -m json.tool" (buffer-name) t)))

(use-package yaml-mode
  :ensure-system-package
  (yaml-language-server . "npm install -g yaml-language-server")
  :hook
  (yaml-mode . (lambda () (define-key yaml-mode-map "\C-m" 'newline-and-indent)))
  :config
  (add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))
  (add-to-list 'auto-mode-alist '("\\.yaml\\'" . yaml-mode)))

(use-package envrc
  :ensure-system-package direnv
  :hook (after-init . envrc-global-mode)
  :config
  (define-key envrc-mode-map (kbd "C-c e") 'envrc-command-map))

(use-package easy-kill-extras
  :demand
  :bind
  (([remap kill-ring-save] . easy-kill) ;; M-w
   ([remap mark-sexp] . easy-mark-sexp) ;; C-M-SPC
   ([remap mark-word] . easy-mark-word) ;; M-@
   ;; 集成 zap-to-char.
   ([remap zap-to-char] . easy-mark-to-char)
   ([remap zap-up-to-char] . easy-mark-up-to-char))
  :init
  (setq kill-ring-max 200
        ;; 替换前先保存剪贴板内容。
        save-interprogram-paste-before-kill t
        easy-kill-alist '((?w word           " ")
                          (?s sexp           "\n")
                          (?l list           "\n")
                          (?d defun          "\n\n")
                          (?D defun-name     " ")
                          (?e line           "\n")
                          (?b buffer-file-name)

                          (?^ backward-line-edge "")
                          (?$ forward-line-edge "")
                          (?h buffer "")
                          (?< buffer-before-point "")
                          (?> buffer-after-point "")
                          (?f string-to-char-forward "")
                          (?F string-up-to-char-forward "")
                          (?t string-to-char-backward "")
                          (?T string-up-to-char-backward "")

                          (?W  WORD " ") ;; a sequence of non-whitespace characters
                          (?\' squoted-string "")
                          (?\" dquoted-string "")
                          (?\` bquoted-string "")
                          (?q  quoted-string "") ;; 任何字符串类型
                          (?Q  quoted-string-universal "")
                          (?\) parentheses-pair-content "\n")
                          (?\( parentheses-pair "\n")
                          (?\] brackets-pair-content "\n")
                          (?\[ brackets-pair "\n")
                          (?}  curlies-pair-content "\n")
                          (?{  curlies-pair "\n")
                          (?>  angles-pair-content "\n")
                          (?<  angles-pair "\n")))
:config
;; 加载 extra-things 后, 上面 WORD 开始的 alist 才生效。
(require 'extra-things))

;; Move to the beginning/end of line or code
(use-package mwim
  :bind (([remap move-beginning-of-line] . mwim-beginning-of-code-or-line)
         ([remap move-end-of-line] . mwim-end-of-code-or-line)))

;; 智能括号。
(use-package smartparens
  :demand
  :config
  (smartparens-global-mode t)
  (show-smartparens-global-mode t))

;; 彩色括号。
(use-package rainbow-delimiters
  :hook
  (prog-mode . rainbow-delimiters-mode))

;; 高亮匹配的括号。
(use-package paren
  :straight (:type built-in)
  :hook
  (after-init . show-paren-mode)
  :init
  (setq show-paren-when-point-inside-paren t
        show-paren-when-point-in-periphery t))

;; 开发文档。
(use-package dash-at-point
  :bind(("C-c d p" . dash-at-point)
        ("C-c d b" . dash-at-point-with-docset)))

(use-package projectile
  :demand
  :config
  (projectile-global-mode)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (projectile-mode +1)
  ;; selectrum/vertico 使用 'default
  (setq projectile-completion-system 'default)
  (add-to-list 'projectile-ignored-projects (concat (getenv "HOME") "/" "/root" "/tmp" "/etc" "/home"))
  (dolist (dirs '(".cache"
                  ".dropbox"
                  ".git"
                  ".hg"
                  ".svn"
                  ".nx"
                  "elpa"
                  "auto"
                  "bak"
                  "__pycache__"
                  "vendor"
                  "node_modules"
                  "logs"
                  "target"
                  ".idea"
                  "build"
                  ".devcontainer"
                  ".settings"
                  ".gradle"
                  ".vscode"))
    (add-to-list 'projectile-globally-ignored-directories dirs))
  (dolist (item '("GPATH"
                  "GRTAGS"
                  "GTAGS"
                  "GSYMS"
                  "TAGS"
                  ".tags"
                  ".classpath"
                  ".project"
                  ".DS_Store"
                  "__init__.py"))
    (add-to-list 'projectile-globally-ignored-files item))
  (dolist (list '("\\.elc\\'"
                  "\\.o\\'"
                  "\\.class\\'"
                  "\\.out\\'"
                  "\\.pdf\\'"
                  "\\.pyc\\'"
                  "\\.rel\\'"
                  "\\.rip\\'"
                  "\\.swp\\'"
                  "\\.iml\\'"
                  "\\.bak\\'"
                  "\\.log\\'"
                  "~\\'"))
    (add-to-list 'projectile-globally-ignored-file-suffixes list))

  ;; Disable projectile on remote buffers
  ;; https://www.murilopereira.com/a-rabbit-hole-full-of-lisp/
  ;; https://github.com/syl20bnr/spacemacs/issues/11381#issuecomment-481239700
  ;;(defadvice projectile-project-root (around ignore-remote first activate)
  ;;  (unless (file-remote-p default-directory 'no-identification) ad-do-it))

  ;; 开启 cache 解决 TRAMP 慢的问题，https://github.com/bbatsov/projectile/pull/1129
  (setq projectile-enable-caching t)
  (setq projectile-file-exists-remote-cache-expire (* 10 60))
  (setq projectile-mode-line-prefix "")
  (setq projectile-dynamic-mode-line nil)
  (setq projectile-sort-order 'recentf)
  (setq projectile-require-project-root 'prompt)
  ;; 添加 :project-file "go.mod", 这样能正确探测 go module (非 git 仓库)根目录。
  (projectile-register-project-type 'go projectile-go-project-test-function
                                    :project-file "go.mod"
                                    :compile "go build"
                                    :test "go test ./..."
                                    :test-suffix "_test"))

(defun my/project-discover ()
  (interactive)
  (dolist (search-path '("~/go/src/github.com/*" "~/go/src/github.com/*/*" "~/go/src/k8s.io/*" "~/go/src/gitlab.*/*/*"))
    (dolist (file (file-expand-wildcards search-path))
      (when (file-directory-p (concat file "/.git"))
        (message "-> %s" file)
        (projectile-add-known-project file)
        (message "added project %s" file)))))

(use-package treemacs
  :demand
  :init
  (with-eval-after-load 'winum (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq
     treemacs-collapse-dirs                 3
     treemacs-deferred-git-apply-delay      0.1
     treemacs-display-in-side-window        t
     treemacs-eldoc-display                 t
     treemacs-file-event-delay              500
     treemacs-file-follow-delay             0.01
     treemacs-follow-after-init             t
     treemacs-git-command-pipe              ""
     treemacs-goto-tag-strategy             'refetch-index
     treemacs-indentation                   1
     treemacs-indentation-string            " "
     treemacs-is-never-other-window         t
     treemacs-max-git-entries               100
     treemacs-missing-project-action        'ask
     treemacs-no-png-images                 nil
     treemacs-no-delete-other-windows       t
     treemacs-persist-file                  (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
     treemacs-position                      'left
     treemacs-recenter-distance             0.01
     treemacs-recenter-after-file-follow    t
     treemacs-recenter-after-tag-follow     t
     treemacs-recenter-after-project-jump   'always
     treemacs-recenter-after-project-expand 'on-distance
     treemacs-shownn-cursor                 t
     treemacs-show-hidden-files             t
     treemacs-silent-filewatch              nil
     treemacs-silent-refresh                nil
     treemacs-sorting                       'alphabetic-asc
     treemacs-select-when-already-in-treemacs 'stay
     treemacs-space-between-root-nodes      nil
     treemacs-tag-follow-cleanup            t
     treemacs-tag-follow-delay              1
     treemacs-width                         35
     treemacs-width-increment               5
     treemacs-width-is-initially-locked     nil
     treemacs-project-follow-cleanup        t
     imenu-auto-rescan                      t)
    (treemacs-resize-icons 11)
    (treemacs-follow-mode t)
    ;;(treemacs-tag-follow-mode t)
    ;;(treemacs-project-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)
    (treemacs-indent-guide-mode t)
    (treemacs-git-mode 'deferred)
    (treemacs-hide-gitignored-files-mode nil))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

;; 单击打开或折叠目录.
(with-eval-after-load 'treemacs
  (define-key treemacs-mode-map [mouse-1] #'treemacs-single-click-expand-action))

(use-package treemacs-projectile
  :after (treemacs projectile))

(use-package treemacs-magit
  :after (treemacs magit))

;; lsp-treemacs 显示 lsp workspace 文件夹和 treemacs projects:
(use-package lsp-treemacs
  :after (lsp-mode treemacs)
  :config
  (setq lsp-treemacs-error-list-current-project-only t)
  (lsp-treemacs-sync-mode 1))

;; C-c p s r(projectile-ripgrep) 依赖 ripgrep 包
(use-package ripgrep
  :ensure-system-package (rg . ripgrep))

(use-package deadgrep
  :ensure-system-package (rg . ripgrep)
  :bind ("<f5>" . deadgrep))

;; OSX 词典。
(use-package osx-dictionary
  :bind
  (("C-c d i" . osx-dictionary-search-input)
   ("C-c d w" . osx-dictionary-search-pointer))
  :config
  (setq osx-dictionary-use-chinese-text-segmentation t))

;; 当前 buffer 文本搜索, 替换 isearch.
(use-package ctrlf
  :config
  (ctrlf-mode +1)
  (add-hook 'pdf-isearch-minor-mode-hook (lambda () (ctrlf-local-mode -1))))

;; browser-url 使用 Mac 默认浏览器。
(setq browse-url-browser-function 'browse-url-default-macosx-browser)

(use-package engine-mode
  :config
  (engine/set-keymap-prefix (kbd "C-c s"))
  (engine-mode t)
  ;;(setq engine/browser-function 'eww-browse-url)
  (defengine github
    "https://github.com/search?ref=simplesearch&q=%s"
    :keybinding "h")

  (defengine google
    "http://www.google.com/search?ie=utf-8&oe=utf-8&q=%s"
    :keybinding "g")

  (defengine twitter
    "https://twitter.com/search?q=%s"
    :keybinding "t")

  (defengine wikipedia
    "http://www.wikipedia.org/search-redirect.php?language=en&go=Go&search=%s"
    :keybinding "w"
    :docstring "Searchin' the wikis."))

;; 添加环境变量 export PATH="/usr/local/opt/curl/bin:$PATH"
(use-package emacs
  :straight (:type built-in)
  :ensure-system-package ("/usr/local/opt/curl/bin/curl" . "brew install curl"))

(setq my/socks-host "127.0.0.1")
(setq my/socks-port 13659)
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
        socks-noproxy '("localhost" "10.0.0.0/8" "172.0.0.0/8" "*cn" "*alibaba-inc.com" "*taobao.com" "*antfin-inc.com")
        socks-server `("Default server" ,my/socks-host ,my/socks-port 5))
  (setenv "all_proxy" my/socks-proxy)
  (proxy-socks-show)
  ;;url-retrieve 使用 curl 作为后端实现, 支持全局 socks5 代理
  (advice-add 'url-http :around 'mb-url-http-around-advice))

(defun proxy-socks-disable ()
  "Disable SOCKS proxy."
  (interactive)
  (require 'socks)
  (setq url-gateway-method 'native
        socks-noproxy nil)
  (setenv "all_proxy" "")
  (proxy-socks-show))

(defun proxy-socks-toggle ()
  "Toggle SOCKS proxy."
  (interactive)
  (require 'socks)
  (if (bound-and-true-p socks-noproxy)
      (proxy-socks-disable)
    (proxy-socks-enable)))

(use-package vterm
  :ensure-system-package
  ((cmake . cmake)
   (glibtool . libtool)
   (exiftran . exiftran))
  :config
  (setq vterm-set-bold-hightbright t)
  (setq vterm-always-compile-module t)
  (setq vterm-max-scrollback 100000)
  ;; vterm buffer 名称，需要配置 shell 来支持（如 bash 的 PROMPT_COMMAND）。
  (setq vterm-buffer-name-string "*vterm: %s")
  (add-hook 'vterm-mode-hook
            (lambda ()
              (setf truncate-lines nil)
              (setq-local show-paren-mode nil)
              (yas-minor-mode -1)
              (flycheck-mode -1)))
  ;; 使用 M-y(consult-yank-pop) 粘贴剪贴板历史中的内容。
  (define-key vterm-mode-map [remap consult-yank-pop] #'vterm-yank-pop)
  :bind
  (:map vterm-mode-map ("C-l" . nil))
  ;; 防止输入法切换冲突。
  (:map vterm-mode-map ("C-\\" . nil)) )

(use-package multi-vterm
  :after (vterm)
  :config
  (define-key vterm-mode-map (kbd "M-RET") 'multi-vterm))

(use-package vterm-toggle
  :after (vterm)
  :custom
  ;; 由于 TRAMP 模式下关闭了 projectile，scope 不能设置为 'project。
  ;;(vterm-toggle-scope 'dedicated)
  (vterm-toggle-scope 'project)
  :config
  (global-set-key (kbd "C-`") 'vterm-toggle)
  (global-set-key (kbd "C-~") 'vterm-toggle-cd)
  (define-key vterm-mode-map (kbd "C-RET") #'vterm-toggle-insert-cd)
  ;; 切换到一个空闲的 vterm buffer 并插入一个 cd 命令， 或者创建一个新的 vterm buffer 。
  (define-key vterm-mode-map (kbd "s-i") 'vterm-toggle-cd-show)
  (define-key vterm-mode-map (kbd "s-n") 'vterm-toggle-forward)
  (define-key vterm-mode-map (kbd "s-p") 'vterm-toggle-backward)
  (define-key vterm-copy-mode-map (kbd "s-i") 'vterm-toggle-cd-show)
  (define-key vterm-copy-mode-map (kbd "s-n") 'vterm-toggle-forward)
  (define-key vterm-copy-mode-map (kbd "s-p") 'vterm-toggle-backward))

(use-package vterm-extra
  :straight (:host github :repo "Sbozzolo/vterm-extra")
  :bind (("s-t" . vterm-extra-dispatcher)
         :map vterm-mode-map
         (("C-c C-e" . vterm-extra-edit-command-in-new-buffer)))
  :config
  (advice-add #'vterm-extra-edit-done :after #'winner-undo))

(setq explicit-shell-file-name "/bin/bash")
(setq shell-file-name "/bin/bash")
(setq shell-command-prompt-show-cwd t)
(setq explicit-bash.exe-args '("--noediting" "--login" "-i"))
(setenv "SHELL" shell-file-name)
(setenv "ESHELL" "bash")
(add-hook 'comint-output-filter-functions 'comint-strip-ctrl-m)

;; 提示符只读
(setq comint-prompt-read-only t)
;; 命令补全
(setq shell-command-completion-mode t)

;; 高亮模式
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on t)

(use-package tramp
  :straight (tramp :files ("lisp/*"))
  :config
  (setq  tramp-ssh-controlmaster-options
         (concat "-o ControlMaster=auto "
                 "-o ControlPath='tramp.%%C' "
                 "-o ControlPersist=600 "
                 "-o ServerAliveCountMax=60 "
                 "-o ServerAliveInterval=10 ")
         ;; TRAMP buffers 关闭 version control, 防止卡住.
         vc-ignore-dir-regexp (format "\\(%s\\)\\|\\(%s\\)" vc-ignore-dir-regexp tramp-file-name-regexp)
         ;; 调大远程文件名过期时间（默认 10s), 提高查找远程文件性能.
         remote-file-name-inhibit-cache 600
         ;;tramp-verbose 10
         ;; 增加压缩传输的文件起始大小（默认 4KB），否则容易出错： “gzip: (stdin): unexpected end of file”
         tramp-inline-compress-start-size (* 1024 8)
         ;; 当文件大小超过 tramp-copy-size-limit 时，用 external methods(如 scp）来传输，从而大大提高拷贝效率。
         tramp-copy-size-limit (* 1024 1024 2)
         ;; 在本地保存 TRAMP auto-save 文件.
         tramp-auto-save-directory (expand-file-name "tramp-auto-save" user-emacs-directory)
         ;; A more representative name for this file.
         tramp-persistency-file-name (expand-file-name "tramp-connection-history" user-emacs-directory)
         ;; 在整个 Emacs session 期间保存 SSH 密码.
         password-cache-expiry nil
         tramp-default-method "ssh"
         tramp-default-remote-shell "/bin/bash"
         tramp-default-user "root"
         tramp-terminal-type "tramp")

  ;; 远程机器列表。
  (require 'epa-file)
  (epa-file-enable)
  (load "~/.emacs.d/sshenv.el.gpg")

  ;; 自定义远程环境变量。
  (let ((process-environment tramp-remote-process-environment))
    ;; 设置远程环境变量 VTERM_TRAMP, 远程机器的 ~/.emacs_bashrc 根据这个变量设置 VTERM 参数。
    (setenv "VTERM_TRAMP" "true")
    (setq tramp-remote-process-environment process-environment)))

;; 切换 buffer 时自动设置 VTERM_HOSTNAME 环境变量为多跳的最后一个主机名，并通过 vterm-environment 传递到远程环境中。远程
;; 机器的 ~/.emacs_bashrc 根据这个变量设置 Buffer 名称和机器访问地址为主机名，正确设置目录跟踪。解决多跳时 IP 重复的问题。
(defvar my/remote-host "")
(add-hook
 'buffer-list-update-hook
 (lambda ()
   (if  (file-remote-p default-directory)
       (progn
         (setq my/remote-host (file-remote-p default-directory 'host))
         ;; 动态计算 ENV=VALUE.
         (require 'vterm)
         (setq vterm-environment `(,(concat "VTERM_HOSTNAME=" my/remote-host)))
         ;; 关闭 treemacs, 避免建立新连接耗时。
         (require 'treemacs)
         (if (string-match "visible" (symbol-name (treemacs-current-visibility)))
             (delete-window (treemacs-get-local-window)))))
   (progn)))

;; 保存 Buffer 时自动更新 #+LASTMOD: 后面的时间戳。
(setq time-stamp-start "#\\+\\(LASTMOD\\|lastmod\\):[ \t]*"
      time-stamp-end "$"
      time-stamp-format "%Y-%m-%dT%02H:%02m:%02S%5z"
      ;; #+LASTMOD: 必须位于文件开头的 line-limit 行内, 否则自动更新不生效。
      time-stamp-line-limit 30)
(add-hook 'before-save-hook 'time-stamp t)

(setq initial-major-mode 'fundamental-mode)

;; 按中文折行。
(setq word-wrap-by-category t)

;; 编辑 grep buffers, 可以和 consult-grep 和 embark-export 联合使用。
(use-package wgrep)
(setq grep-highlight-matches t)

;; 退出自动杀掉进程。
(setq confirm-kill-processes nil)

;; 使用 fundamental-mode 打开大文件。
(defun my/large-file-hook ()
  (when (and (> (buffer-size) (* 1024 2))
             (or (string-equal (file-name-extension (buffer-file-name)) "json")
                 (string-equal (file-name-extension (buffer-file-name)) "yaml")
                 (string-equal (file-name-extension (buffer-file-name)) "yml")
                 (string-equal (file-name-extension (buffer-file-name)) "log")))
    (fundamental-mode)
    (setq buffer-read-only t)
    ;;(buffer-disable-undo)
    (font-lock-mode -1)
    (rainbow-delimiters-mode -1)
    (smartparens-global-mode -1)
    (show-smartparens-mode -1)
    (smartparens-mode -1)))
(add-hook 'find-file-hook 'my/large-file-hook)
;; 默认直接用 fundamental-mode 打开 json 和 log 文件, 确保其它 major-mode 不会先执行。
(add-to-list 'auto-mode-alist '("\\.log?\\'" . fundamental-mode))
(add-to-list 'auto-mode-alist '("\\.json?\\'" . fundamental-mode))

(use-package winner
  :straight (:type built-in)
  :commands (winner-undo winner-redo)
  :hook (after-init . winner-mode)
  :init
  (setq winner-boring-buffers
        '("*Completions*"
          "*Compile-Log*"
          "*inferior-lisp*"
          "*helpful"
          "*lsp-help*"
          "*Fuzzy Completions*"
          "*Apropos*"
          "*Help*"
          "*cvs*"
          "*Buffer List*"
          "*Ibuffer*"
          "*esh command on file*")))

;; macOS 按键调整。
(setq mac-command-modifier 'meta)
;; option 作为 Super 键(按键绑定用 s- 表示，S- 表示 Shift)
(setq mac-option-modifier 'super)
;; fn 作为 Hyper 键(按键绑定用 H- 表示)
(setq ns-function-modifier 'hyper)

(use-package emacs
  :straight (:type built-in)
  :init
  (setq use-short-answers t)
  (setq confirm-kill-emacs #'y-or-n-p)
  ;; 关闭出错提示声。
  (setq visible-bell nil)
  (setq ring-bell-function 'ignore)
  ;; 不创建 lock 文件。
  (setq create-lockfiles nil)
  ;; 启动 Server 。
  (unless (and (fboundp 'server-running-p)
               (server-running-p))
    (server-start)))

;; bookmark 发生变化时自动保存（默认是 Emacs 正常退出时保存）。
(setq bookmark-save-flag 1)

;; 避免执行 ns-print-buffer 命令。
(global-unset-key (kbd "s-p"))
;; 避免执行 ns-open-file-using-panel 命令。
(global-unset-key (kbd "s-o"))
(global-unset-key (kbd "s-t"))
(global-unset-key (kbd "s-n"))
;; 关闭 suspend-frame 。
(global-unset-key (kbd "C-z"))

(use-package recentf
  :straight (:type built-in)
  :config
  ;; 不清理 recentf tramp buffers .
  (setq recentf-auto-cleanup 'never)
  (setq recentf-max-menu-items 30)
  (setq recentf-max-saved-items 5000)
  (setq recentf-exclude `(,(expand-file-name "straight/" user-emacs-directory)
                          ,(expand-file-name "eln-cache/" user-emacs-directory)
                          ,(expand-file-name "etc/" user-emacs-directory)
                          ,(expand-file-name "var/" user-emacs-directory)
                          ,(expand-file-name ".cache/" user-emacs-directory)
                          "/tmp" ".gz" ".tgz" ".xz" ".zip" "/ssh:" ".png" ".jpg" "/\\.git/" ".gitignore" "\\.log"
                          ,(concat package-user-dir "/.*-autoloads\\.el\\'")))
  (recentf-mode +1))

(setq global-mark-ring-max 5000)
(setq mark-ring-max 5000 )
(setq kill-ring-max 5000)

(global-set-key (kbd "RET") 'newline-and-indent)

;; Minibuffer 历史。
(use-package savehist
  :straight (:type built-in)
  :hook (after-init . savehist-mode)
  :config
  (setq history-length 10000)
  (setq history-delete-duplicates t)
  (setq savehist-save-minibuffer-history t)
  (setq savehist-autosave-interval 60)
  (setq savehist-additional-variables '(mark-ring
                                        global-mark-ring
                                        search-ring
                                        regexp-search-ring
                                        extended-command-history)))

;; fill-column 的值应该小于 visual-fill-column-width，否则居中显示时行内容会过长而被隐藏。
(setq-default fill-column 100
              comment-fill-column 0
              tab-width 4
              ;; 不插入 tab (按照 tab-width 转换为空格插入) 。
              indent-tabs-mode nil
              message-log-max t
              load-prefer-newer t
              ad-redefinition-action 'accept)

;; 使用系统剪贴板，实现与其它程序相互粘贴。
(setq x-select-enable-clipboard t)
(setq select-enable-clipboard t)
(setq x-select-enable-primary t)
(setq select-enable-primary t)

;; 粘贴于光标处, 而不是鼠标指针处。
(setq mouse-yank-at-point t)

(use-package ibuffer
  :straight (:type built-in)
  :bind
  ("C-x C-b" . ibuffer)
  :config
  (setq ibuffer-expert t)
  (setq ibuffer-display-summary nil)
  (setq ibuffer-use-other-window t)
  ;; 隐藏空组。
  (setq ibuffer-show-empty-filter-groups nil)
  (setq ibuffer-movement-cycle nil)
  (setq ibuffer-default-sorting-mode 'filename/process)
  (setq ibuffer-use-header-line t)
  (setq ibuffer-default-shrink-to-minimum-size nil)
  (setq ibuffer-saved-filter-groups nil)
  (setq ibuffer-old-time 48)
  (add-hook 'ibuffer-mode-hook #'hl-line-mode))

;; 基于 project 来对 buffer 进行分组。
(use-package ibuffer-projectile
  :after (ibuffer projectile)
  :hook
  ((ibuffer . (lambda ()
                (ibuffer-projectile-set-filter-groups)
                (unless (eq ibuffer-sorting-mode 'alphabetic)
                  (ibuffer-do-sort-by-alphabetic)))))
  :config
  ;; 显示的文件名是相对于 project root 的相对路径。
  (setq ibuffer-formats
        '((mark modified read-only " "
                (name 18 18 :left :elide)
                " "
                (size 9 -1 :right)
                " "
                (mode 16 16 :left :elide)
                " "
                project-relative-file))))

(use-package dired
  :straight (:type built-in)
  :config
  ;; re-use dired buffer, available in Emacs 28
  ;; @see https://debbugs.gnu.org/cgi/bugreport.cgi?bug=20598
  (setq dired-kill-when-opening-new-dired-buffer t)
  ;; "always" means no asking
  (setq dired-recursive-copies 'always)
  ;; "top" means ask once for top level directory
  (setq dired-recursive-deletes 'top)
  ;; search file name only when focus is over file
  (setq dired-isearch-filenames 'dwim)
  ;; if another Dired buffer is visible in another window, use that directory as target for Rename/Copy
  (setq dired-dwim-target t)
  ;; @see https://emacs.stackexchange.com/questions/5649/sort-file-names-numbered-in-dired/5650#5650
  (setq dired-listing-switches "-laGh1v --group-directories-first")
  (dired-async-mode 1)
  (put 'dired-find-alternate-file 'disabled nil))

;; dired 显示高亮增强。
(use-package diredfl
  :config
  (diredfl-global-mode))

(use-package undo-tree
  :init
  (global-undo-tree-mode 1))

(defvar backup-dir (expand-file-name "~/.emacs.d/backup/"))
(if (not (file-exists-p backup-dir))
    (make-directory backup-dir t))
;; 文件第一次保存时备份。
(setq make-backup-files t)
(setq backup-by-copying t)
(setq backup-directory-alist (list (cons ".*" backup-dir)))
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

;; UTF8 中文字符。
(setq locale-coding-system 'utf-8)
(setq default-buffer-file-coding-system 'utf-8)
(set-default buffer-file-coding-system 'utf8)
(prefer-coding-system 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(set-language-environment "UTF-8")
(set-default-coding-systems 'utf-8)
(setenv "LANG" "zh_CN.UTF-8")
(setenv "LC_ALL" "zh_CN.UTF-8")
(setenv "LC_CTYPE" "zh_CN.UTF-8")

;; 删除文件时, 将文件移动到回收站。
(use-package osx-trash
  :ensure-system-package trash
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
