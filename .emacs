(package-initialize)

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(package-initialize)

;; Prevent tabs and use 4 space tab stop
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq-default indent-line-function 'insert-tab)

;; Put backup files in one place
(setq backup-directory-alist '(("." . "~/.emacs.d/backups")))

;; Put auto-save files in one place
(setq auto-save-file-name-transforms '((".*" "~/.emacs.d/autosaves/" t)))

;; Allow y/n answers instead of yes/no
(defalias 'yes-or-no-p 'y-or-n-p)

;; Disable beeping
(setq-default visible-bell t)

;; Enable syntax highlighting
(global-font-lock-mode t)
(setq-default font-lock-maximum-decoration t)

;; Disable auto indenting
(electric-indent-mode 0)

;; Show trailing whitespace
;; https://www.emacswiki.org/emacs/WhiteSpace
(require 'whitespace)
(setq-default whitespace-style '(face trailing tabs))
(custom-set-faces '(whitespace-tab ((t (:background "red")))))
(global-whitespace-mode)
