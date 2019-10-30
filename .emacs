; Send automatic custom additions to a different file
(setq custom-file "~/.emacs.d/custom.el")
(when (file-exists-p custom-file)
  (load custom-file))

; Set up package repositories to use
(package-initialize)
(require 'package)

(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

; Packages to use and make sure we have installed
(setq package-list '(dracula-theme))

(package-install-selected-packages)

; Load theme
; https://draculatheme.com/emacs/
(load-theme 'dracula t)

; Prevent tabs and use 4 space tab stop
(setq indent-tabs-mode nil)
(setq tab-width 4)
(setq indent-line-function 'insert-tab)

; Put backup files in one place
(setq backup-directory-alist '(("." . "~/.emacs.d/backups")))

; Put auto-save files in one place
(setq auto-save-file-name-transforms '((".*" "~/.emacs.d/autosaves/" t)))

; Allow y/n answers instead of yes/no
(defalias 'yes-or-no-p 'y-or-n-p)

; Disable beeping
(setq visible-bell t)

; Enable syntax highlighting
(global-font-lock-mode t)
(setq font-lock-maximum-decoration t)

; Disable auto indenting
(electric-indent-mode 0)

; Show line numbers and column numbers by default
; Bind M-# to toggle line number mode on/off
(setq column-number-mode t)
(global-set-key (kbd "M-#") 'display-line-numbers-mode)

; Show trailing whitespace
; https://www.emacswiki.org/emacs/WhiteSpace
(require 'whitespace)
(setq whitespace-style '(face trailing tabs))
(custom-set-faces '(whitespace-tab ((t (:background "red")))))
(global-whitespace-mode)

; Smooth scrolling rather than jumping by half a screenful
(setq scroll-step 1)

; Show the clock
(display-time-mode 1)

; Wrap email at 78 characters max per line
(add-hook 'mail-mode-hook (lambda () (set-fill-column 78)))
(add-hook 'mail-mode-hook 'turn-on-auto-fill)

; Set modes based on filename or file extension
(add-to-list 'auto-mode-alist '("(GNUmakefile|makefile|Makefile)" . makefile-mode))
(add-to-list 'auto-mode-alist '("\\.py$" . python-mode))
(add-to-list 'auto-mode-alist '(".*tmp\/mutt-.*[0-9]+$" . mail-mode))
