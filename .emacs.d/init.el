; Send automatic custom additions to a different file
(setq custom-file "~/.emacs.d/custom.el")
(when (file-exists-p custom-file)
    (load custom-file))

; Install things from MELPA if we don't have tham
(require 'package)

; Package repositories
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/") t)
(add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/nongnu/") t)

; Package repository priorities
(setq package-archive-priorities '(("melpa-stable" . 10)
                                   ("melpa" . 8)
                                   ("gnu" . 6)
                                   ("nongnu" . 2)))

; Activate all the packages (in particular autoloads)
(package-initialize)

; Refresh package repo contents if necessary
(when (not package-archive-contents)
    (package-refresh-contents))

; Packages to install
;     'use-package'          Emacs install may not have it
;     'org'                  Orgmode - https://orgmode.org/
;     'ggtags'               GNU Global frontend
;                            https://github.com/leoliu/ggtags
;     'rust-mode'            Rust syntax highlighting
;                            https://github.com/rust-lang/rust-mode
;     'borland-blue-theme'   Recreates that awesome Borland DOS IDE
;     'py-autopep8'          Autoformat Python to PEP8
;     'elpy'                 Python development environment
;     'magit'                Emacs git interface
;     'docker-compose-mode'  Docker mode
;     'dockerfile-mode'      Docker mode
;     'yaml-mode'            YAML major mode
;     'markdown-mode'        MarkDown major mode

(setq my-package-list
    '(use-package org ggtags))

(dolist (package my-package-list)
    (unless (package-installed-p package)
        (package-install package)))

; Theme it up
(push (substitute-in-file-name "~/.emacs.d/themes/") custom-theme-load-path)
(load-theme 'borland-blue t)

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
(add-hook 'after-change-major-mode-hook (lambda() (electric-indent-mode 0)))

; Disable automatic formatting
(setq lsp-enable-on-type-formatting nil)

; Show line numbers and column numbers by default
; Bind M-# to toggle line number mode on/off
(setq column-number-mode t)
(global-set-key (kbd "M-#") 'display-line-numbers-mode)

; Smooth scrolling rather than jumping by half a screenful
(setq scroll-step 1)

; Show the clock
(display-time-mode 1)

; Show trailing whitespace
; https://www.emacswiki.org/emacs/WhiteSpace
; (Does not appear to work for comment lines, but maybe I can fix that
; one day.)
(require 'whitespace)
(setq whitespace-style '(face trailing tabs))
(custom-set-faces '(whitespace-tab ((t (:background "red")))))
(global-whitespace-mode)

; Prevent lots of trailing whitespace on mouse copy/paste
;(unless window-system
;    (custom-set-faces
;        '(default ((t (:background "unspecified-bg"))))))

; How to compose email
(defun mutt-mail-mode-hook ()
    (flush-lines "^\\(>\n\\)*>-- \n\\(\n?>.*\\)*") ; kill quoted sigs
    (setq fill-column 78)
    ;(setq auto-fill-function 'do-auto-fill)
    (setq indent-line-function 'nil)
    (not-modified)
    (mail-text)
    (setq make-backup-files nil))
(or (assoc "mutt-" auto-mode-alist)
    (setq auto-mode-alist (cons '(".*tmp\/mutt-.*[0-9]+$" . mail-mode) auto-mode-alist)))

; Helper function to select the message body
(defun mutt-select-body ()
    (interactive)
    (save-excursion
        (goto-line 0)
        (move-beginning-of-line nil)
        (while (looking-at-p "^.+:.*$")            ; advance past header
            (forward-line 1))
        (while (looking-at-p "^$")                 ; advance past blank lines
            (forward-line 1))
        (let ((pos (line-beginning-position)))     ; save current position
            (while (not (looking-at-p "^--\\s+$")) ; advance to signature
                (forward-line 1))
            (set-mark pos))))

;        (set-mark-command nil)                     ; begin marking body
;        (while (not (looking-at-p "^--\\s+$"))     ; mark to signature
;            (forward-line 1))
;        (setq deactivate-mark nil)))

; Helper function to produce RFC2646 format=flowed email
; https://lists.gnu.org/archive/html/help-gnu-emacs/2005-05/msg00821.html
(defun mutt-reflow-body ()
    (interactive)
    (save-excursion
        (goto-char (point-min))
        (while (< (point) (point-max))
            (end-of-line)
            (if (or (= 0 (current-column))  ; empty line
                    (looking-at "\n\\s-"))  ; bo(next)l whitespace
                (delete-horizontal-space)
                (just-one-space))
            (forward-line 1))))

; When launched from mutt, put us in email composing mode
(add-hook 'mail-mode-hook 'mutt-mail-mode-hook)

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
(add-hook 'org-mode-hook 'turn-on-auto-fill)

; Set the terminal window title
; [I don't like the output of the terminal window name, but that's
; because I abuse mkstemp in mutt and other programs., but I'm leaving
; the code here in case I want it in the future.]
;(defun xterm-title-update ()
;    (interactive)
;    (send-string-to-terminal (concat "\033]2;emacs: " (buffer-name) "\007")))
;(add-hook 'post-command-hook 'xterm-title-update)

; Function to insert my weekly status report file in to the current
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
(defun insert-weeklystatus ()
    (interactive)
    (insert-file-contents "~/Desktop/weeklystatus.org"))
(global-set-key (kbd "M-S") 'insert-weeklystatus)

; Kill all sessions and the daemon if I feel so inclined
(defun server-shutdown ()
    "Save buffers, Quit, and Shutdown (kill) server"
    (interactive)
    (save-some-buffers)
    (kill-emacs))
(global-set-key (kbd "C-c x") 'server-shutdown)

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

; GDB
(setq
 ;; use gdb-many-windows by default
 gdb-many-windows t

 ;; Non-nil means display source file containing the main routine at startup
 gdb-show-main t
 )

; Diff mode highlighting adjustments (my pupils!)
(defun update-diff-colors ()
  "update the colors for diff faces"
  (set-face-attribute 'diff-added nil
                      :foreground "white" :background "blue")
  (set-face-attribute 'diff-removed nil
                      :foreground "white" :background "red3")
  (set-face-attribute 'diff-changed nil
                      :foreground "white" :background "purple"))
(eval-after-load "diff-mode"
  '(update-diff-colors))

; Try to help when things go wrong
(setq debug-on-error t)

; Load Rust syntax highlighting
;(require 'rust-mode)
;(setq rust-format-on-save t)
;(add-hook 'rust-mode-hook
;          (lambda () (setq indent-tabs-mode nil)))
;(add-hook 'rust-mode-hook
;          (lambda () (prettify-symbols-mode)))

; Set modes based on filename or file extension
(add-to-list 'auto-mode-alist '("(GNUmakefile|makefile|Makefile)" . makefile-mode))
(add-to-list 'auto-mode-alist '("\\.py$" . python-mode))
(add-to-list 'auto-mode-alist '(".*tmp\/mutt-.*[0-9]+$" . mail-mode))
;(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode))
