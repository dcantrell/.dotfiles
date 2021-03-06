; Send automatic custom additions to a different file
(setq custom-file "~/.emacs.d/custom.el")
(when (file-exists-p custom-file)
  (load custom-file))

; Set up package repositories to use
(package-initialize)
(require 'package)

(add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/") t)

(unless package--initialized (package-initialize t))
(unless package-archive-contents
  (package-refresh-contents))

; Packages to use and make sure we have installed
; NOTE: This claims to be automatically installable via melpa, but that
; does not always work for me.  https://draculatheme.com/emacs/
; Adding here manually so my dotfiles collection always works.
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
(setq package-list '(dracula-theme org magit))

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
