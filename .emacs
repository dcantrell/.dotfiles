; Set up package repositories to use
(package-initialize)
(require 'package)

(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

; Packages to use and make sure we have installed
(setq package-list '(solarized-theme distinguished-theme))

(dolist (package package-list)
  (unless (package-installed-p package)
    (package-install package)))

; Load theme
(setq-default solarized-distinct-fringe-background t)
(setq-default solarized-emphasize-indicators nil)
(load-theme 'solarized-dark t)

; Bind 'C-x t' to toggle between default and dark theme
(defun toggle-theme ()
  (interactive)
  (if (eq (car custom-enabled-themes) 'solarized-dark)
      (disable-theme 'solarized-dark)
    (enable-theme 'solarized-dark)))
(global-set-key (kbd "C-x t") 'toggle-theme)

; Prevent tabs and use 4 space tab stop
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq-default indent-line-function 'insert-tab)

; Put backup files in one place
(setq backup-directory-alist '(("." . "~/.emacs.d/backups")))

; Put auto-save files in one place
(setq auto-save-file-name-transforms '((".*" "~/.emacs.d/autosaves/" t)))

; Allow y/n answers instead of yes/no
(defalias 'yes-or-no-p 'y-or-n-p)

; Disable beeping
(setq-default visible-bell t)

; Enable syntax highlighting
(global-font-lock-mode t)
(setq-default font-lock-maximum-decoration t)

; Disable auto indenting
(electric-indent-mode 0)

; Show line numbers and column numbers by default
; Bind M-# to toggle line number mode on/off
(setq-default column-number-mode t)
(global-set-key (kbd "M-#") 'display-line-numbers-mode)

; Show trailing whitespace
; https://www.emacswiki.org/emacs/WhiteSpace
(require 'whitespace)
(setq-default whitespace-style '(face trailing tabs))
(custom-set-faces
  ; custom-set-faces was added by Custom.
  ; If you edit it by hand, you could mess it up, so be careful.
  ; Your init file should contain only one such instance.
  ; If there is more than one, they won't work right.
  '(whitespace-tab ((t (:background "red")))))
(global-whitespace-mode)

; Smooth scrolling rather than jumping by half a screenful
(setq-default scroll-step 1)

; Show the clock
(display-time-mode 1)

; Set modes based on filename or file extension
(add-to-list 'auto-mode-alist '("(GNUmakefile|makefile|Makefile)" . makefile-mode))
(add-to-list 'auto-mode-alist '("\\.py$" . python-mode))
(add-to-list 'auto-mode-alist '(".*tmp\/mutt-.*[0-9]+$" . mail-mode))


(custom-set-variables
  ; custom-set-variables was added by Custom.
  ; If you edit it by hand, you could mess it up, so be careful.
  ; Your init file should contain only one such instance.
  ; If there is more than one, they won't work right.
  '(package-selected-packages (quote (distinguished-theme))))
