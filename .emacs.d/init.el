
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

;; Use OSX-style super keys in terminals too. Requires mapping them in
;; terminal emulator as well.
(unless (display-graphic-p)
  (progn
    (global-set-key (kbd "s-u") 'revert-buffer)
    (global-set-key (kbd "s-l") 'goto-line)))

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

(defun now ()
  "Insert string for the current time formatted like '2:34 PM'."
  (interactive)                 ; permit invocation in minibuffer
  (insert (format-time-string "%D %-I:%M %p")))

;; variables and settings not in any package; in C-source code
(if (display-graphic-p)
    (progn
      (set-fontset-font t 'unicode "Apple Color Emoji" nil 'prepend)
      (tool-bar-mode -1))
  (menu-bar-mode -1))

(setq-default indent-tabs-mode nil)
(setq-default indicate-buffer-boundaries 'left)
(setq-default indicate-empty-lines t)
(setq-default scroll-conservatively 1)
(setq-default scroll-preserve-screen-position 1)
(setq-default fill-column 110)
(setq ring-bell-function 'ignore)

;; don't create temporary files or symlinks
(setq make-backup-files nil)
(setq auto-save-default nil)
(setq create-lockfiles nil)


;; custom local packages
(eval-and-compile
  (defun markdown-preview-load-path ()
    (concat (getenv "HOME") "/src/markdown-preview/")))

(eval-and-compile
  (defun pdrestclient-load-path ()
    (concat (getenv "HOME") "/src/pdrestclient.el/")))

(eval-and-compile
  (defun lsp-python-ms-load-path ()
    (concat (getenv "HOME") "/src/lsp-python-ms/")))

;; packages

(use-package ace-jump-mode
  :ensure t
  :bind (("M-i" . ace-jump-mode)
         ("s-i" . ace-jump-mode-pop-mark)))

(use-package ace-window
  :ensure t
  :bind (("M-p" . ace-window)))

(use-package beacon
  :ensure t
  :config
  (beacon-mode 1))

(use-package company
  :ensure t
  :bind (("C-M-i" . company-complete)))

(use-package company-lsp
  :ensure t
  :after (company lsp-mode)
  :config
  (add-to-list 'company-backends 'company-lsp))

(use-package copyright
  :config
  (setq copyright-year-ranges t)
  (add-hook 'prog-mode-hook
            '(lambda() (add-hook 'before-save-hook 'copyright-update))))

(use-package cua-base
  :config
  (setq cua-enable-cua-keys nil)             ; only used for rectangle editing
  (cua-mode t))

(use-package desktop
  :config
  (setq desktop-save-mode t))

(use-package dockerfile-mode
  :ensure t)

(use-package ediff
  :config
  (defun local-ediff-before-setup-hook ()
    (setq local-ediff-saved-window-configuration (current-window-configuration)))
  (defun local-ediff-quit-hook ()
    (set-window-configuration local-ediff-saved-window-configuration))
  (defun local-ediff-suspend-hook ()
    (set-window-configuration local-ediff-saved-window-configuration))
  (add-hook 'ediff-before-setup-hook 'local-ediff-before-setup-hook)
  (add-hook 'ediff-quit-hook 'local-ediff-quit-hook 'append)
  (add-hook 'ediff-suspend-hook 'local-ediff-suspend-hook 'append)
  (setq ediff-split-window-function 'split-window-horizontally)
  (setq ediff-window-setup-function 'ediff-setup-windows-plain))

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

(use-package ein
  :ensure t)

(use-package elisp-mode
  :config
  (add-hook 'before-save-hook 'delete-trailing-whitespace nil t))

(use-package files
  :config
  (setq auto-save-default nil)
  (setq confirm-kill-emacs 'y-or-n-p)
  (when (eq system-type 'darwin)
    (setq insert-directory-program "/usr/local/bin/gls")) ; use gnu ls which supports --dired
  (setq require-final-newline t)
  (add-hook 'hack-local-variables-hook
            (lambda () (when (derived-mode-p 'python-mode)
                         (venv-workon venv-name)
                         (lsp)))))

(use-package flycheck
  :ensure t
  :config
  (setq flycheck-emacs-lisp-load-path 'inherit)
  (add-hook 'elisp-mode-hook 'flycheck-mode)
  (add-hook 'ruby-mode-hook 'flycheck-mode))

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

(use-package git-timemachine
  :ensure t
  )

(use-package go-mode
  :ensure t
  :config
  (when (eq system-type 'darwin)
    (setenv "GOROOT" "/usr/local/opt/go/libexec")
    (setenv "GOPATH" "/Users/cmcdaniel/go"))

  ;; note: we duplicate the use of goimports in lsp-mode to make the lsp-format-buffer command work. But it is
  ;; much slower than calling goimports locally, so we'll use that for our before-save-hook.
  (setq gofmt-command "goimports")
  (setq gofmt-args '("-local" "github.atl.pdrop.net"))
  (add-hook 'go-mode-hook (lambda()
                            (setq tab-width 4)
                            (add-hook 'before-save-hook #'gofmt-before-save nil 'local))))

(use-package go-playground
  :ensure t)

(use-package grep
  :config
  (setq grep-find-ignored-directories (append grep-find-ignored-directories '("deb_dist"
                                                                              "dist"
                                                                              "build"
                                                                              "*venv*"
                                                                              "system_test/report"
                                                                              "pb-python"
                                                                              "protocol"
                                                                              "passport_trials"
                                                                              "datascience-toolbox"
                                                                              "lcov-report")))
  (setq grep-find-ignored-files (append grep-find-ignored-files '("*.gz" "*.deb" "*.vox" "*.hdf5" "*.pkl" "*.pdf" "*.pcap" "*.npz" "collector" "predictor" "bigBlacklistConfig.json" "bigWhitelistConfig.json"))))

(use-package groovy-mode
  :ensure t
  :config
  (add-hook 'groovy-mode-hook
            (lambda ()
              (setq c-basic-offset 4)
              (c-set-offset 'label 4))))

(use-package hl-line
  :config
  (global-hl-line-mode))

(use-package ht
  :ensure t)

(use-package ibuffer
  :config
  (setq ibuffer-default-sorting-mode 'filename/process)
  :bind (("C-x C-b" . ibuffer)))        ; instead of list-buffers

(use-package js
  :config
  (setq js-indent-level 2))

(use-package locate
  :config
  (setq locate-command "~/bin/locate-with-mdfind"))

(use-package lsp-mode
  :ensure t
  :hook ((go-mode . lsp)
         (rust-mode . lsp))
  :config
  (setenv "GO111module" "off")
  (define-key lsp-mode-map (kbd "C-c C-o i") 'lsp-find-implementation)
  (define-key lsp-mode-map (kbd "C-c C-o j") 'lsp-find-definition)
  (define-key lsp-mode-map (kbd "C-c C-o r") 'lsp-find-references)
  (setq lsp-clients-go-server-args '("-build-tags" "servicetest service"))
  (setq lsp-clients-go-imports-local-prefix "github.atl.pdrop.net"))

(use-package lsp-python-ms
  :ensure nil
  :load-path (lambda () (list (lsp-python-ms-load-path)))
  :config
  ;; for dev build of language server
  (setq lsp-python-ms-dir
        (expand-file-name "~/src/python-language-server/output/bin/Release/"))
  ;; for executable of language server
  (setq lsp-python-ms-executable
        (expand-file-name "~/src/python-language-server/output/bin/Release/osx-x64/publish/Microsoft.Python.LanguageServer")))

(use-package lsp-ui
  :ensure t
  :after (lsp-mode)
  :init
  (setq lsp-ui-doc-enable nil)
  (setq lsp-ui-sideline-show-code-actions nil)
  ;; (setq lsp-ui-sideline-show-diagnostics nil)
  (setq lsp-ui-sideline-show-hover nil)
  (setq lsp-ui-sideline-show-symbol nil)
  :hook ((lsp-mode . lsp-ui-mode)
	 (lsp-mode . flycheck-mode))
  :config
  (setq lsp-prefer-flymake nil))

(use-package magit
  :ensure t
  :bind (("C-x g" . magit-status)))

(use-package markdown-mode
  :ensure t
  :config
  (setq markdown-command "~/.virtualenvs/emacs/bin/markdown_py -x mdx_gfm"))

(use-package markdown-preview
  :load-path (lambda () (list (markdown-preview-load-path))))

(use-package material-theme
  :ensure t
  :config
  (load-theme 'material t))

(defun multi-term-split-window-right ()
  (interactive)
  (split-window-right)
  (other-window 1)
  (multi-term))

(defun multi-term-split-window-below ()
  (interactive)
  (split-window-below)
  (other-window 1)
  (multi-term))

(use-package multi-term
  :ensure t
  :config
  (setq term-unbind-key-list '("C-x" "C-c" "C-h" "C-y" "<ESC>"))
  (setq term-bind-key-alist '(
    ("C-c C-c" . term-interrupt-subjob)
    ("C-c C-e" . term-send-esc)
    ("C-c C-k" . term-char-mode)
    ("C-c C-j" . term-line-mode)
    ("C-p" . term-send-up)
    ("C-n" . term-send-down)
    ("C-m" . term-send-return)
    ("C-y" . term-paste)
    ("M-f" . term-send-forward-word)
    ("M-b" . term-send-backward-word)
    ("M-o" . term-send-backspace)
    ("M-p" . term-send-up)
    ("M-n" . term-send-down)
    ("M-M" . term-send-forward-kill-word)
    ("M-N" . term-send-backward-kill-word)
    ("<C-backspace>" . term-send-backward-kill-word)
    ("M-r" . term-send-reverse-search-history)
    ("M-d" . term-send-delete-word)
    ("M-," . term-send-raw)
    ("C-c 2" . multi-term-split-window-below)
    ("C-c 3" . multi-term-split-window-right))))

(use-package nxml-mode
  :config
  (setq nxml-slash-auto-complete-flag t))

(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)))

(use-package ob-restclient
  :ensure t
  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((restclient . t))))

(defun my-babel-to-buffer ()
  (interactive)
  (org-open-at-point)
  (org-babel-remove-result))

(use-package ob
  :bind (:map org-babel-map
              ("\C-k" . org-babel-remove-result)
              ("k" . org-babel-remove-result)
              ("\C-m" . my-babel-to-buffer)
              ("m" . my-babel-to-buffer)))

(use-package pdrestclient
  :config (load "~/src/pdrestclient.el.tokens/tokens.el" 'noerror)
  :load-path (lambda () (list (pdrestclient-load-path))))

(use-package projectile
  :ensure t)

(use-package protobuf-mode
  :ensure t
  :config
  (defconst my-protobuf-style
    '((c-basic-offset . 4)
      (indent-tabs-mode . nil)))
  (add-hook 'protobuf-mode-hook
            (lambda () (c-add-style "my-style" my-protobuf-style t))))

(use-package python
  :requires lsp-python-ms
  :bind (:map python-mode-map
              ("s-[" . python-indent-shift-left)
              ("s-]" . python-indent-shift-right))
  :config
  (defun my-python-hook()
    (setq python-indent-guess-indent-offset nil)
    (modify-syntax-entry ?_ "w")         ; Make underscores part of a word
    (setenv "LANG" "en_US.UTF-8"))
  (add-hook 'python-mode-hook 'my-python-hook))

(use-package rainbow-delimiters
  :ensure t
  :config
  (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))

(use-package replace
  :bind (([f5] . query-replace-regexp)))

(use-package restclient
  :ensure t)

(use-package rust-mode
  :ensure t
  :config
  (add-hook 'rust-mode-hook #'rust-enable-format-on-save)
  (setq rust-format-on-save t))

(use-package cargo
  :ensure t
  :after (rust-mode))

(use-package rg
  :ensure t
  :config
  (rg-enable-default-bindings))

(use-package rust-playground
  :ensure t
  :after (rust-mode))

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
  (setq shift-select-mode nil)
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

(use-package time
  :config
  (display-time-mode 1))

(use-package uniquify
  :config
  (setq uniquify-buffer-name-style 'forward))

(use-package virtualenvwrapper
  :ensure t)

(use-package windmove
  :ensure t
  :config
  (setq windmove-wrap-around t)

  ;; match iTerm2 bindings
  :bind (([M-s-left] . windmove-left)
         ([M-s-right] . windmove-right)
         ([M-s-up] . windmove-up)
         ([M-s-down] . windmove-down)))

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

(use-package yaml-mode
  :ensure t)

(use-package yasnippet-snippets
  :ensure t)

(use-package zoom-window
  :ensure t)

(defun safe-local-variable-p (sym val)
  "Put your guard logic here, return t when sym is ok, nil otherwise"
  (member sym '(exec-path encoding org-confirm-babel-evaluate lexical-binding venv-name)))
