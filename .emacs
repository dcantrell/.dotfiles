; NOTE: You must manually install 'use-package' then exit and restart emacs.
; M-x package-refresh-contents <RET>
; M-x package-install <RET>
; use-package <RET>

; Pick up local packages (*.el files)
(add-to-list 'load-path "~/.emacs.d/local/")

; Send automatic custom additions to a different file
(setq custom-file "~/.emacs.d/custom.el")
(when (file-exists-p custom-file)
  (load custom-file))

; Set up package repositories to use
(package-initialize)
(require 'package)
(setq use-package-always-ensure t)

(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/") t)

; Packages to use and make sure we have installed
; NOTE: This claims to be automatically installable via melpa, but that
; does not always work for me.  https://draculatheme.com/emacs/
; Adding here manually so my dotfiles collection always works.
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")

(use-package dracula-theme)
(use-package org)
(use-package magit)
(use-package ggtags)
(use-package cc-mode)
(use-package semantic)

; This is not in MELPA but is from here:
; https://www.emacswiki.org/emacs/download/sr-speedbar.el
; I just save it to ~/.emacs.d
(require 'sr-speedbar)

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

; Wrap email at 74 characters max per line
(add-hook 'mail-mode-hook (lambda () (set-fill-column 74)))
(add-hook 'mail-mode-hook 'turn-on-auto-fill)
(add-hook 'mail-mode-hook 'mail-abbrevs-setup)
(add-hook 'mail-mode-hook (lambda () (setq 'indent-line-function 'nil)))

; Set modes based on filename or file extension
(add-to-list 'auto-mode-alist '("(GNUmakefile|makefile|Makefile)" . makefile-mode))
(add-to-list 'auto-mode-alist '("\\.py$" . python-mode))
(add-to-list 'auto-mode-alist '(".*tmp\/mutt-.*[0-9]+$" . mail-mode))

; Prevent lots of trailing whitespace on mouse copy/paste
(unless window-system
  (custom-set-faces
   '(default ((t (:background "unspecified-bg"))))))

; Work around problem with the X selection and getting extra spaces
; only on commented lines
(defun yank-to-x-clipboard () (interactive)
  (if (region-active-p)
      (progn (shell-command-on-region (region-beginning)
                                      (region-end)
                                      "xclip -i -selection primary")
             (shell-command-on-region (region-beginning)
                                      (region-end)
                                      "xclip -i -selection clipboard")
             (message "Yanked region to clipboard!")
             (deactivate-mark))
    (message "No region active; can't yank to clipboard!")))
(global-set-key "\M-W" 'yank-to-x-clipboard)

; Org-mode
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-font-lock-mode 1)

; Set the terminal window title
; [I don't like the output of the terminal window name, but that's
; because I abuse mkstemp in mutt and other programs., but I'm leaving
; the code here in case I want it in the future.]
;(defun xterm-title-update ()
;    (interactive)
;    (send-string-to-terminal (concat "\033]2;emacs: " (buffer-name) "\007")))
;(add-hook 'post-command-hook 'xterm-title-update)

; When in org-mode, enable auto-fill-mode
(add-hook 'org-mode-hook 'turn-on-auto-fill)

; Function to insert my daily status report file in to the current
; buffer.  I use this from mutt when composing a status report email.
; At some point in the future I will extend this to compose the
; message for me and then eventually send it.  For now I am just
; inserting the file contents.  Bind it to M-S.
;
; TODO:
; * Insert two lines below the last mail header
; * Make sure there's only a single blank line before the sig
; * Work without positioning the point
; * Construct outgoing email and send it
(defun insert-dailystatus ()
    (interactive)
    (insert-file-contents "~/dailystatus.org"))
(global-set-key (kbd "M-S") 'insert-dailystatus)

;;;;;;;;;;;;;;;;;;;
;; C Development ;;
;;;;;;;;;;;;;;;;;;;

; GNU global and universal ctags and pygments for C development
(require 'ggtags)
(add-hook 'c-mode-common-hook
    (lambda ()
        (when (derived-mode-p 'c-mode 'c++-mode 'java-mode)
            (ggtags-mode 1))))

; ggtags keybindings for common operations
(define-key ggtags-mode-map (kbd "C-c g s") 'ggtags-find-other-symbol)
(define-key ggtags-mode-map (kbd "C-c g h") 'ggtags-view-tag-history)
(define-key ggtags-mode-map (kbd "C-c g r") 'ggtags-find-reference)
(define-key ggtags-mode-map (kbd "C-c g f") 'ggtags-find-file)
(define-key ggtags-mode-map (kbd "C-c g c") 'ggtags-create-tags)
(define-key ggtags-mode-map (kbd "C-c g u") 'ggtags-update-tags)

(define-key ggtags-mode-map (kbd "M-,") 'pop-tag-mark)

; Find definitions in the current buffer
(setq-local imenu-create-index-function #'ggtags-build-imenu-index)

; Semantic setup
(global-semanticdb-minor-mode 1)
(global-semantic-idle-scheduler-mode 1)
(semantic-mode 1)
(global-semantic-idle-summary-mode 1)

; GDB
(setq
 ;; use gdb-many-windows by default
 gdb-many-windows t

 ;; Non-nil means display source file containing the main routine at startup
 gdb-show-main t
 )
