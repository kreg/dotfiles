
;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))

(unless package-archive-contents
  (package-refresh-contents))

(when (not (package-installed-p `use-package))
  (package-install 'use-package))

;; the customizations file
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file 'noerror)

;; keys I do not like
(global-unset-key "\C-z")               ; don't use this key to minimize
(global-unset-key "\C-x\C-z")           ; don't use this key to minimize
(global-unset-key (kbd "s-p"))          ; don't use this key to print

;; replace y-e-s by y
(defalias 'yes-or-no-p 'y-or-n-p)

;; these disabled by default; enable them
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)

;; use a nice title bar
(setq frame-title-format
      (list (format "emacs@%s%%S:%%j " (system-name))
            '(buffer-file-name "%f" (dired-directory dired-directory "%b"))))

(defun create-scratch-buffer ()
  "Recreate the scratch buffer."
  (interactive)
  (switch-to-buffer (get-buffer-create "*scratch*"))
  (lisp-interaction-mode))


;; variables and settings not in any package; in C-source code
(set-fontset-font t 'unicode "Apple Color Emoji" nil 'prepend)
(set-fill-column 110)
(tool-bar-mode -1)
(setq-default indent-tabs-mode nil)
(setq-default indicate-buffer-boundaries 'left)
(setq-default indicate-empty-lines t)
(setq-default scroll-conservatively 1)
(setq-default scroll-preserve-screen-position 1)

;; packages

(use-package ace-jump-mode
  :ensure t
  :bind (("M-i" . ace-jump-mode)
         ("s-i" . ace-jump-mode-pop-mark)))

(use-package company
  :ensure t
  :config
  (add-hook 'python-mode-hook
            '(lambda()
               (company-mode)
               (add-to-list 'company-backends 'company-jedi)
               (local-set-key (kbd "C-M-i") 'company-complete))))

(use-package company-jedi
  :ensure t
  )

(use-package copyright
  :config
  (add-hook 'prog-mode-hook '(lambda() (add-hook 'before-save-hook 'copyright-update))))

(use-package cua-base
  :config
  (setq cua-enable-cua-keys nil)             ; only used for rectangle editing
  (cua-mode t))

(use-package desktop
  :config
  (setq desktop-save-mode t))

(use-package ediff
  :config
  (defun local-ediff-before-setup-hook ()
    (setq local-ediff-saved-frame-configuration (current-frame-configuration))
    (setq local-ediff-saved-window-configuration (current-window-configuration)))
  (defun local-ediff-quit-hook ()
    (set-frame-configuration local-ediff-saved-frame-configuration)
    (set-window-configuration local-ediff-saved-window-configuration))
  (defun local-ediff-suspend-hook ()
    (set-frame-configuration local-ediff-saved-frame-configuration)
    (set-window-configuration local-ediff-saved-window-configuration))
  (add-hook 'ediff-before-setup-hook 'local-ediff-before-setup-hook)
  (add-hook 'ediff-quit-hook 'local-ediff-quit-hook 'append)
  (add-hook 'ediff-suspend-hook 'local-ediff-suspend-hook 'append)
  (setq ediff-split-window-function 'split-window-horizontally))

(use-package edit-server
  :ensure t
  :config
  (setq edit-server-new-frame nil)
  (edit-server-start))

(use-package executable
  :config
  (add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p))

(use-package exec-path-from-shell
  :ensure t
  :config
  (exec-path-from-shell-initialize))

(use-package faces
  :config
  (set-face-attribute 'default nil :family "Menlo" :height 140))

(use-package face-remap
  :bind (("s-=" . text-scale-increase)
         ("s--" . text-scale-decrease)))

(use-package elisp-mode
  :config
  (add-hook 'before-save-hook 'delete-trailing-whitespace nil t))

(use-package files
  :config
  (setq auto-save-default nil)
  (setq confirm-kill-emacs 'y-or-n-p)
  (setq insert-directory-program "/usr/local/bin/gls") ; use gnu ls which supports --dired
  (setq make-backup-files nil)
  (setq require-final-newline t)
  (setq safe-local-variable-values '((encoding . utf-8))))

(use-package flycheck
  :ensure t
  :config
  (setq flycheck-emacs-lisp-load-path 'inherit)
  (setq flycheck-python-flake8-executable "~/virtualenvs/emacs/bin/flake8")
  (setq-default flycheck-flake8-maximum-line-length 110)
  (add-hook 'elisp-mode-hook 'flycheck-mode)
  (add-hook 'ruby-mode-hook 'flycheck-mode)
  (add-hook 'python-mode-hook 'flycheck-mode))

(use-package flx
  :ensure t
  :init
  (setq gc-cons-threshold 20000000)) ; recommended by https://github.com/lewang/flx

(use-package flx-ido
  :ensure t
  :config
  (ido-mode 1)
  (ido-everywhere 1)
  (flx-ido-mode 1)
  (setq ido-enable-flex-matching t)
  (setq ido-use-faces nil))    ; disable ido faces to see flx highlights.

(use-package frame
  :config
  (set-cursor-color "tomato1")
  (setq blink-cursor-mode nil))

(use-package grep
  :config
  (setq grep-find-ignored-directories (append grep-find-ignored-directories '("deb_dist"  "dist" "build")))
  (setq grep-find-ignored-files (append grep-find-ignored-files '("*.gz" "*.deb"))))

(use-package groovy-mode
  :ensure t
  :config
  (add-hook 'groovy-mode-hook
            (lambda ()
              (setq c-basic-offset 4)
              (c-set-offset 'label 4))))

(use-package ibuffer
  :bind (("C-x C-b" . ibuffer)))        ; instead of list-buffers

(use-package jedi-core
  :ensure t
  :config
  (add-hook 'python-mode-hook
            '(lambda()
               (local-set-key (kbd "M-.") 'jedi:goto-definition)
               (local-set-key (kbd "C-c C-k") 'jedi:show-doc))))

(use-package js
  :config
  (setq js-indent-level 2))

(use-package locate
  :config
  (setq locate-command "~/bin/locate-with-mdfind"))

(use-package magit
  :ensure t
  :bind (("C-x g" . magit-status)))

(use-package markdown-mode
  :ensure t
  :config
  (setq markdown-command "~/virtualenvs/emacs/bin/markdown_py -x mdx_gfm"))

(use-package material-theme
  :ensure t
  :config
  (load-theme 'material t))

(use-package nxml-mode
  :config
  (setq nxml-slash-auto-complete-flag t))

(use-package python
  :bind (:map python-mode-map
              ("C-m" . sp-newline)
              ("s-[" . python-indent-shift-left)
              ("s-]" . python-indent-shift-right))
  :config
  (defun my-python-hook()
    (setq python-indent-guess-indent-offset nil)
    (setq python-check-command "~/virtualenvs/emacs/bin/flake8 --max-line-length=110")
    (set-fill-column 110)
    (modify-syntax-entry ?_ "w")         ; Make underscores part of a word
    (setenv "LANG" "en_US.UTF-8"))
  (add-hook 'python-mode-hook 'my-python-hook))

(use-package rainbow-delimiters
  :ensure t
  :config
  (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))

(use-package scroll-bar
  :config
  (setq scroll-bar-mode nil))

(use-package server
  :config
  (server-mode t))

(use-package simple
  :config
  (setq column-number-mode t)
  (setq kill-whole-line t)
  (setq size-indication-mode t))

(use-package smartparens
  :ensure t
  :config
  (require 'smartparens-config)
  (show-smartparens-global-mode t)
  (add-hook 'prog-mode-hook 'smartparens-mode))

(use-package smex
  :ensure t
  :config
  (smex-initialize)
  :bind (("M-x" . smex)
         ([f8] . smex)
         ("M-X" . smex-major-mode-commands)))

(use-package uniquify
  :config
  (setq uniquify-buffer-name-style 'forward))

(use-package windmove
  :ensure t
  :config
  (windmove-default-keybindings 'super)
  (setq windmove-wrap-around t))

(use-package window
  :bind (([up] . scroll-down-line)      ; already have C-p for previous-line
         ([down] . scroll-up-line))     ; already have C-n for next-line
  :init
  (setq split-height-threshold nil)     ; these had to be in :init instead of :config for some reason
  (setq split-width-threshold 220))

(use-package yasnippet
  :ensure t
  :config
  (yas-global-mode 1))  
