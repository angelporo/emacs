;; Emacs 28
(when (fboundp 'native-compile-async)
  (setenv "LIBRARY_PATH"
          (concat (getenv "LIBRARY_PATH")
                  "/usr/local/opt/gcc/lib/gcc/11:/usr/local/opt/gcc/lib/gcc/11/gcc/x86_64-apple-darwin20/11.2.0"))
  (setq native-comp-speed 2
        native-comp-async-jobs-number 4
        native-comp-deferred-compilation nil
        native-comp-deferred-compilation-deny-list '()
        native-comp-async-report-warnings-errors 'silent))

(setq byte-compile-warnings '(cl-functions))

;; 关闭 package.el(后续使用 straight.el)
(setq package-enable-at-startup nil)

(setq debug-on-error t)
(add-hook 'emacs-startup-hook (lambda () (setq debug-on-error nil)))

;; Mac native fullscreen 会导致白屏和左右滑动问题，故使用传统全屏模式。
(when (eq system-type 'darwin)
  (setq ns-use-native-fullscreen nil
        ns-use-fullscreen-animation nil))

;;(set-frame-parameter (selected-frame) 'fullscreen 'maximized)
;;(add-hook 'after-init-hook #'toggle-frame-fullscreen)

(set-frame-parameter (selected-frame) 'maximized 'fullscreen)
(add-hook 'after-init-hook #'toggle-frame-maximized)

;; 第一个 frame 规格
(setq initial-frame-alist '((top . 10 ) (left . 10) (width . 200) (height . 60)))
;; 后续 frame 规格
(setq default-frame-alist '((top . 10 ) (left . 10) (width . 200) (height . 60)))

;; 在单独文件保存自定义配置
(setq custom-file (expand-file-name "~/.emacs.d/custom.el"))
(add-hook 'after-init-hook (lambda () (when (file-exists-p custom-file) (load custom-file))))

;; 个人信息
(setq user-full-name "zhangjun"
      user-mail-address "geekard@qq.com")

;; 使用 minibuffer 输入 GPG 密码。
(setq epa-pinentry-mode 'loopback)

;; 加密认证信息文件
(setq auth-sources '("~/.authinfo.gpg")
      auth-source-cache-expiry nil) ; default is 7200 (2h)
;;(setq auth-source-debug t)

(defun org-clocking-buffer (&rest _))
