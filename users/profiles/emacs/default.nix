{ pkgs, ... }:

{
  services.emacs = {
    enable = true;
  };

  programs.emacs = {
    enable = true;
    #package = pkgs.emacsPgtk;
    init = {
      enable = true;
      recommendedGcSettings = true;

      prelude = ''
                ;; Disable startup message.
                (setq inhibit-startup-screen t
                      inhibit-startup-echo-area-message (user-login-name))

                (setq initial-major-mode 'fundamental-mode
                      initial-scratch-message nil)

                ;; Disable some GUI distractions.
                (tool-bar-mode -1)
                (scroll-bar-mode -1)
                (menu-bar-mode -1)
                (blink-cursor-mode 0)
                (desktop-save-mode 1)

                ;; Set up fonts early.
                (set-face-attribute 'default
                                    nil
                                    :height 80
                                    :family "Fantasque Sans Mono")
                (set-face-attribute 'variable-pitch
                                    nil
                                    :family "DejaVu Sans")

                ;; Set frame title.
                (setq frame-title-format
                      '("" invocation-name ": "(:eval
                                                (if (buffer-file-name)
                                                    (abbreviate-file-name (buffer-file-name))
                                                  "%b"))))
                ;; transparency
                (set-frame-parameter (selected-frame) 'alpha '(90 . 80))
                (add-to-list 'default-frame-alist '(alpha . (90 . 80)))

                ;; Accept 'y' and 'n' rather than 'yes' and 'no'.
                (defalias 'yes-or-no-p 'y-or-n-p)

                ;; Don't want to move based on visual line.
                (setq line-move-visual nil)

                ;; Stop creating backup and autosave files.
                (setq make-backup-files nil
                      auto-save-default nil)

                ;; Always show line and column number in the mode line.
                (line-number-mode)
                (column-number-mode)
                (global-display-line-numbers-mode 1)

                ;; Enable some features that are disabled by default.
                (put 'narrow-to-region 'disabled nil)

                ;; Typically, I only want spaces when pressing the TAB key. I also
                ;; want 4 of them.
                (setq-default indent-tabs-mode nil
                              tab-width 4
                              c-basic-offset 4)

                ;; Trailing white space are banned!
                (setq-default show-trailing-whitespace t)

                ;; Make a reasonable attempt at using one space sentence separation.
                (setq sentence-end "[.?!][]\"')}]*\\($\\|[ \t]\\)[ \t\n]*"
                      sentence-end-double-space nil)

                ;; I typically want to use UTF-8.
                (prefer-coding-system 'utf-8)

                ;; Nicer handling of regions.
                (transient-mark-mode 1)

                ;; Make moving cursor past bottom only scroll a single line rather
                ;; than half a page.
                (setq scroll-step 1
                      scroll-conservatively 5)

                ;; Enable highlighting of current line.
                (global-hl-line-mode 1)

                ;; Improved handling of clipboard in GNU/Linux and otherwise.
                (setq select-enable-clipboard t
                      select-enable-primary t
                      save-interprogram-paste-before-kill t)

                ;; Pasting with middle click should insert at point, not where the
                ;; click happened.
                (setq mouse-yank-at-point t)

                ;; Turn on mouse
                (xterm-mouse-mode t)

                ;; Enable a few useful commands that are initially disabled.
                (put 'upcase-region 'disabled nil)
                (put 'downcase-region 'disabled nil)

                ;; (setq custom-file (locate-user-emacs-file "custom.el"))
                ;; (load custom-file)

                ;; When finding file in non-existing directory, offer to create the
                ;; parent directory.
                (defun with-buffer-name-prompt-and-make-subdirs ()
                  (let ((parent-directory (file-name-directory buffer-file-name)))
                    (when (and (not (file-exists-p parent-directory))
                      (y-or-n-p (format "Directory `%s' does not exist! Create it? " parent-directory)))
                      (make-directory parent-directory t))))

                (add-to-list 'find-file-not-found-functions #'with-buffer-name-prompt-and-make-subdirs)

                ;; Don't want to complete .hi files.
                (add-to-list 'completion-ignored-extensions ".hi")

                (defun rah-disable-trailing-whitespace-mode ()
                  (setq show-trailing-whitespace nil))

                ;; Shouldn't highlight trailing spaces in terminal mode.
                (add-hook 'term-mode #'rah-disable-trailing-whitespace-mode)
                (add-hook 'term-mode-hook #'rah-disable-trailing-whitespace-mode)

                ;; Remove trailing white space upon saving
                ;; Note: because of a bug in EIN we only delete trailing whitespace
                ;; when not in EIN mode.
                (add-hook 'before-save-hook
                          (lambda ()
                            (when (not (derived-mode-p 'ein:notebook-multilang-mode))
                          (delete-trailing-whitespace))))

                ;; Check (on save) whether the file edited contains a shebang, if yes,
                ;; make it executable from
                ;; http://mbork.pl/2015-01-10_A_few_random_Emacs_tips
                (add-hook 'after-save-hook #'executable-make-buffer-file-executable-if-script-p)


                ;; Auto-wrap at 80 characters
                (setq-default auto-fill-function 'do-auto-fill)
                (setq-default fill-column 80)
                (turn-on-auto-fill)

                ;; Disable auto-fill-mode in programming mode
                (add-hook 'prog-mode-hook (lambda () (auto-fill-mode -1)))

                ;; Non-nil means draw block cursor as wide as the glyph under it.
                ;; For example, if a block cursor is over a tab, it will be drawn as
                ;; wide as that tab on the display.
                (setq x-stretch-cursor t)

                ;; Overwrite region selected
                (delete-selection-mode t)


                (setq modus-themes-mode-line '(borderless))

                (setq modus-themes-vivendi-color-overrides
                  '((bg-main . nil)
                    (bg-dim . nil)
                    (bg-alt . nil)
                    (bg-active . nil)
                    (bg-inactive . nil)))

                (load-theme 'modus-vivendi t)


                ;; Eshell?

        ;;; Use TRAMP to use Eshell as root.
        (require 'em-tramp)
        (setq password-cache t)
        (setq password-cache-expiry 3600)

        (require 'eshell)
        (require 'em-smart)
        (setq eshell-where-to-jump 'begin)
        (setq eshell-review-quick-commands nil)
        (setq eshell-smart-space-goes-to-end t)

        ;; If the above does not work, try uncommenting this.
        (add-to-list 'eshell-modules-list 'eshell-smart)
        (add-to-list 'eshell-modules-list 'eshell-tramp)

        (with-eval-after-load 'esh-module
          ;; REVIEW: It used to work, but now the early `provide' seems to backfire.
          (unless (boundp 'eshell-modules-list)
            (load "esh-module"))
          ;; Don't print the banner.
          (delq 'eshell-banner eshell-modules-list)
          (push 'eshell-tramp eshell-modules-list))

        (setq
          eshell-ls-use-colors t
          ;; ffap-shell-prompt-regexp changes the behaviour of `helm-find-files' when
          ;; point is on prompt. I find this disturbing.
          ffap-shell-prompt-regexp nil
          eshell-history-size 262144
          eshell-hist-ignoredups t
          eshell-destroy-buffer-when-process-dies t)

                (defun with-face (str &rest face-plist)
                  (propertize str 'face face-plist))
                  (defun custom-eshell-prompt ()
          (let* (
                ;; Get the git branch.
                (git-branch-unparsed
                  (shell-command-to-string "git rev-parse --abbrev-ref HEAD 2>/dev/null"))
                  (git-branch
                  (if (string= git-branch-unparsed "")
                      ""
                    ;; Remove the trailing newline.
                    (substring git-branch-unparsed 0 -1)))
          )
            (concat
              ;; Timestamp.
              (with-face
              (format-time-string "[%a, %b %d | %H:%M:%S]\n" (current-time))
              :inherit font-lock-builtin-face)
              ;; Directory.
              (with-face (concat (eshell/pwd) " ") :inherit font-lock-constant-face)
              ;; Git branch.
              (unless (string= git-branch "")
                (with-face (concat "[" git-branch "]") :inherit font-lock-string-face))
              "\n"
              ;; Prompt.
              ;; NOTE: Need to keep " $" for the next/previous prompt regexp to work.
              (with-face " $" :inherit font-lock-preprocessor-face)

            )))
        (setq eshell-prompt-function 'custom-eshell-prompt)
        (setq eshell-highlight-prompt nil)

        (defun ambrevar/eshell-prompt ()
          (let ((path (abbreviate-file-name (eshell/pwd))))
            (concat
              (when ambrevar/eshell-status-p
                (propertize (or (ambrevar/eshell-status-display) "") 'face font-lock-comment-face))
              (format
              (propertize "(%s@%s)" 'face '(:weight bold))
              (propertize (user-login-name) 'face '(:foreground "cyan"))
              (propertize (system-name) 'face '(:foreground "cyan")))
              (if (and (require 'magit nil t) (or (magit-get-current-branch) (magit-get-current-tag)))
                  (let* ((prefix (abbreviate-file-name (magit-rev-parse "--show-prefix")))
                        (before-prefix (substring-no-properties path nil (when (/= 0 (length prefix)) (- (length prefix))))))
                    (format
                    (propertize "[%s/%s@%s]" 'face '(:weight bold))
                    (propertize before-prefix 'face `(:foreground ,(if (= (user-uid) 0) "red" "green") :weight bold))
                    (propertize prefix 'face `(:foreground ,(if (= (user-uid) 0) "orange" "gold")))
                    (or (magit-get-current-branch) (magit-get-current-tag))))
                (format
                (propertize "[%s]" 'face '(:weight bold))
                (propertize path 'face `(:foreground ,(if (= (user-uid) 0) "red" "green") :weight bold))))
              (propertize "\nλ$" 'face '(:weight bold))
              " ")))

        ;;; Leave `eshell-highlight-prompt' to t as it sets the read-only property.
        (setq eshell-prompt-function #'ambrevar/eshell-prompt)
        ;;; If the prompt spans over multiple lines, the regexp should match
        ;;; last line only.
        (setq-default eshell-prompt-regexp "^λ$ ")

        (with-eval-after-load 'em-term
          (dolist (p '("abook" "alsamixer" "cmus" "fzf" "gtypist" "htop" "mpsyt" "mpv" "mutt" "ncdu" "newsbeuter" "pinentry-curses" "nmtui" "ssh" "watch" "wifi-menu"))
            (add-to-list 'eshell-visual-commands p))
          (setq eshell-visual-subcommands
                ;; Some Git commands use a pager by default.
                ;; Either invoke the subcommands in a term ("visual") or configure Git
                ;; to disable the pager globally.
                ;; '(("git" "log" "diff" "show")
                '(("sudo" "wifi-menu") ; Arch Linux
                  ("sudo" "vi" "visudo"))))

        ;;; Shared history.
        (defvar ambrevar/eshell-history-global-ring nil
          "The history ring shared across Eshell sessions.")

        (defun ambrevar/eshell-hist-use-global-history ()
          "Make Eshell history shared across different sessions."
          (unless ambrevar/eshell-history-global-ring
            (when eshell-history-file-name
              (eshell-read-history nil t))
            (setq ambrevar/eshell-history-global-ring (or eshell-history-ring (make-ring eshell-history-size))))
          (setq eshell-history-ring ambrevar/eshell-history-global-ring))
        (add-hook 'eshell-mode-hook 'ambrevar/eshell-hist-use-global-history)

        ;;; Extra execution information
        (defvar ambrevar/eshell-status-p t
          "If non-nil, display status before prompt.")
        (defvar ambrevar/eshell-status--last-command-time nil)
        (make-variable-buffer-local 'ambrevar/eshell-status--last-command-time)
        (defvar ambrevar/eshell-status-min-duration-before-display 1
          "If a command takes more time than this, display its duration.")

        (defun ambrevar/eshell-status-display ()
          (when ambrevar/eshell-status--last-command-time
            (let ((duration (time-subtract (current-time) ambrevar/eshell-status--last-command-time)))
              (setq ambrevar/eshell-status--last-command-time nil)
              (when (> (time-to-seconds duration) ambrevar/eshell-status-min-duration-before-display)
                (format "#[STATUS] End time %s, duration: %s\n"
                        (format-time-string "%F %T" (current-time))
                        (modi/seconds-to-human-time (time-to-seconds duration)))))))
                ;; (format "#[STATUS] End time %s, duration %.3fs\n"
                ;;         (format-time-string "%F %T" (current-time))
                ;;         (time-to-seconds duration))))))


        (defun ambrevar/eshell-status-record ()
          (setq ambrevar/eshell-status--last-command-time (current-time)))

        (add-hook 'eshell-pre-command-hook 'ambrevar/eshell-status-record)

        ;; Eshell direnv


                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; Enable terminal emacs to copy and paste from system clipboard
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; Note: this uses C-c before the usual C-w, M-w, and C-y
                ;; From: https://stackoverflow.com/questions/64360/how-to-copy-text-from-emacs-to-another-application-on-linux
                ;; FIXME, COPY and CUT need extra work
                (defun my-copy-to-xclipboard(arg)
                  (interactive "P")
                  (cond
                    ((not (use-region-p))
                    (message "Nothing to yank to X-clipboard"))
                    ((and (not (display-graphic-p))
                      (/= 0 (shell-command-on-region
                                (region-beginning) (region-end) "wl-copy")))
                    (message "Error: Is program `xsel' installed?"))
                    (t
                    (when (display-graphic-p)
                      (call-interactively 'clipboard-kill-ring-save))
                    (message "Yanked region to X-clipboard")
                    (when arg
                      (kill-region  (region-beginning) (region-end)))
                    (deactivate-mark))))

                (defun my-cut-to-xclipboard()
                  (interactive)
                  (my-copy-to-xclipboard t))

                (defun my-paste-from-xclipboard()
                  (interactive)
                  (if (display-graphic-p)
                      (clipboard-yank)
                    (insert (shell-command-to-string "wl-paste"))))

                (global-set-key [(control shift x)] 'my-cut-to-xclipboard)
                (global-set-key [(control shift c)] 'my-copy-to-xclipboard)
                (global-set-key [(control shift v)] 'my-paste-from-xclipboard)

                ;; Treat clipboard input as UTF-8 string first; compound text next, etc.
                (setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING))


        (defun my/org-present-start ()
          (visual-fill-column-mode 1)
          (visual-line-mode 1))
        (defun my/org-present-end ()
          (visual-fill-column-mode 0)
          (visual-line-mode 0))

      '';

      usePackage = {
        abbrev = {
          enable = true;
          diminish = [ "abbrev-mode" ];
          command = [ "abbrev-mode" ];
        };

        adoc-mode = {
          enable = true;
          mode = [
            ''"\\.txt\\'"''
            ''"\\.adoc\\'"''
          ];
        };
        all-the-icons = {
          enable = true;
        };
        ansi-color = {
          enable = true;
          command = [ "ansi-color-apply-on-region" ];
        };

        autorevert = {
          enable = true;
          diminish = [ "auto-revert-mode" ];
          command = [ "auto-revert-mode" ];
        };

        back-button = {
          enable = true;
          defer = 1;
          diminish = [ "back-button-mode" ];
          command = [ "back-button-mode" ];
          config = ''
            (back-button-mode 1)

            ;; Make mark ring larger.
            (setq global-mark-ring-max 50)
          '';
        };

        # base16-theme = {
        #   enable = true;
        #   config = "(load-theme 'base16-tomorrow-night t)";
        # };

        calc = {
          enable = true;
          command = [ "calc" ];
          config = ''
            (setq calc-date-format '(YYYY "-" MM "-" DD " " Www " " hh ":" mm ":" ss))
          '';
        };

        # From https://github.com/mlb-/emacs.d/blob/a818e80f7790dffa4f6a775987c88691c4113d11/init.el#L472-L482
        compile = {
          enable = true;
          defer = true;
          after = [ "ansi-color" ];
          hook = [
            ''
              (compilation-filter . (lambda ()
                                      (when (eq major-mode 'compilation-mode)
                                        (ansi-color-apply-on-region compilation-filter-start (point-max)))))
            ''
          ];
        };

        beacon = {
          enable = true;
          command = [ "beacon-mode" ];
          diminish = [ "beacon-mode" ];
          defer = 1;
          config = "(beacon-mode 1)";
        };

        cc-mode = {
          enable = true;
          defer = true;
          hook = [
            ''
              (c-mode-common . (lambda ()
                (subword-mode)
                (c-set-offset 'arglist-intro '++)))
            ''
          ];
        };
        crdt = {
          enable = true;
        };
        dash = {
          enable = true;
        };
        equake = {
          enable = true;
          config = ''
            :custom
            (equake-size-width 0.99)
            ;; set distinct face for Equake: white foreground with dark blue background, and different font:
            :custom-face
            (equake-buffer-face
              ((t (:inherit 'default :family "DejaVu Sans Mono" :background "#000022" :foreground "white"))))
            :config
            ;; prevent accidental frame closure:
            (advice-add #'save-buffers-kill-terminal :before-while #'equake-kill-emacs-advice)
            ;; binding to restore last Equake tab when viewing a non-Equake buffer
            (global-set-key (kbd "C-M-^") #'equake-restore-last-etab)
            ;; set default shell
            (setq equake-default-shell 'vterm)
            ;; set list of available shells
            (setq equake-available-shells
              '("shell"
                "vterm"
                "rash"
                "eshell"))
          '';
        };
        deadgrep = {
          enable = true;
          bind = {
            "C-x f" = "deadgrep";
          };
        };

        direnv = {
          enable = true;
          command = [ "direnv-mode" "direnv-update-environment" ];
          hook = [
            "(add-hook 'eshell-directory-change-hook #'direnv-update-directory-environment)"
          ];
        };

        dhall-mode = {
          enable = true;
          mode = [ ''"\\.dhall\\'"'' ];
        };

        dockerfile-mode = {
          enable = true;
          mode = [ ''"Dockerfile\\'"'' ];
        };

        doom-modeline = {
          enable = true;
          hook = [ "(after-init . doom-modeline-mode)" ];
          config = ''
            (setq doom-modeline-buffer-file-name-style 'truncate-except-project)
          '';
        };
        modus-themes = {
          enable = true;
        };
        # doom-themes = {
        #   enable = true;
        #   config = ''
        #     ;; Global settings (defaults)
        #     (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        #       doom-themes-enable-italic t) ; if nil, italics is universally disabled
        #     (load-theme 'doom-one t)

        #     ;; Enable custom neotree theme (all-the-icons must be installed!)
        #     ;;(doom-themes-neotree-config)

        #     ;; or for treemacs users
        #     ;; (setq doom-themes-treemacs-theme "doom-colors") ; use the colorful treemacs theme
        #     ;;(doom-themes-treemacs-config)

        #     ;; Corrects (and improves) org-mode's native fontification.
        #     ;; (doom-themes-org-config)
        #   '';
        # };
        drag-stuff = {
          enable = true;
          bind = {
            "M-<up>" = "drag-stuff-up";
            "M-<down>" = "drag-stuff-down";
          };
        };

        ediff = {
          enable = true;
          defer = true;
          config = ''
            (setq ediff-window-setup-function 'ediff-setup-windows-plain)
          '';
        };

        eldoc = {
          enable = true;
          diminish = [ "eldoc-mode" ];
          command = [ "eldoc-mode" ];
        };

        # Enable Electric Indent mode to do automatic indentation on RET.
        electric = {
          enable = true;
          command = [ "electric-indent-local-mode" ];
          hook = [
            "(prog-mode . electric-indent-mode)"

            # Disable for some modes.
            "(nix-mode . (lambda () (electric-indent-local-mode -1)))"
          ];
        };

        elm-mode = {
          enable = true;
          mode = [ ''"\\.elm\\'"'' ];
        };
        envrc = {
          enable = true;
          config = ''
            (envrc-global-mode)
          '';
        };
        epresent = {
          enable = true;
        };
        # Eshell
        esh-autosuggest = {
          enable = true;
          hook = [
            "(add-hook 'eshell-mode-hook 'esh-autosuggest-mode)"
          ];
          config = ''
            (setq esh-autosuggest-delay 0.75)
              (define-key esh-autosuggest-active-map (kbd "<tab>") 'company-complete-selection)
          '';
        };
        eshell-info-banner = {
          enable = true;
          defer = true;
          hook = [
            "(eshell-banner-load . eshell-info-banner-update-banner)"
          ];
        };
        etags = {
          enable = true;
          defer = true;
          # Avoid spamming reload requests of TAGS files.
          config = "(setq tags-revert-without-query t)";
        };
        go-mode = {
          enable = true;
          mode = [
            ''("\\.go\\'" . go-mode)''
          ];
        };
        solidity-mode = {
          enable = true;
          mode = [
            ''("\\.sol\\'" . solidity-mode)''
          ];
        };
        elixir-mode = {
          enable = true;
          mode = [
            ''("\\.exs\\'" . elixir-mode)''
          ];
        };
        ggtags = {
          enable = true;
          defer = true;
          diminish = [ "ggtags-mode" ];
          command = [ "ggtags-mode" ];
        };

        groovy-mode = {
          enable = true;
          mode = [
            ''"\\.gradle\\'"''
            ''"\\.groovy\\'"''
            ''"Jenkinsfile\\'"''
          ];
        };

        #idris-mode = {
        #  enable = true;
        #  mode = [ ''"\\.idr\\'"'' ];
        #};

        ispell = {
          enable = true;
          defer = 1;
        };

        js = {
          enable = true;
          mode = [
            ''("\\.js\\'" . js-mode)''
            ''("\\.json\\'" . js-mode)''
          ];
          config = ''
            (setq js-indent-level 2)
          '';
        };

        notifications = {
          enable = true;
          command = [ "notifications-notify" ];
        };

        flyspell = {
          enable = true;
          diminish = [ "flyspell-mode" ];
          command = [ "flyspell-mode" "flyspell-prog-mode" ];
          hook = [
            # Spell check in text and programming mode.
            "(text-mode . flyspell-mode)"
            "(prog-mode . flyspell-prog-mode)"
          ];
          config = ''
            ;; In flyspell I typically do not want meta-tab expansion
            ;; since it often conflicts with the major mode. Also,
            ;; make it a bit less verbose.
            (setq flyspell-issue-message-flag nil
                  flyspell-issue-welcome-flag nil
                  flyspell-use-meta-tab nil)
          '';
        };

        # Remember where we where in a previously visited file. Built-in.
        saveplace = {
          enable = true;
          config = ''
            (setq-default save-place t)
            (setq save-place-file (locate-user-emacs-file "places"))
          '';
        };

        # More helpful buffer names. Built-in.
        uniquify = {
          enable = true;
          defer = 2;
          config = ''
            (setq uniquify-buffer-name-style 'post-forward)
          '';
        };

        # Hook up hippie expand.
        hippie-exp = {
          enable = true;
          bind = {
            "M-?" = "hippie-expand";
          };
        };

        which-key = {
          enable = true;
          command = [ "which-key-mode" ];
          diminish = [ "which-key-mode" ];
          defer = 2;
          config = "(which-key-mode)";
        };

        # Enable winner mode. This global minor mode allows you to
        # undo/redo changes to the window configuration. Uses the
        # commands C-c <left> and C-c <right>.
        winner = {
          enable = true;
          config = "(winner-mode 1)";
        };

        # This was causing problem with taking C-S-V as M-[
        # writeroom-mode = {
        #   enable = true;
        #   command = [ "writeroom-mode" ];
        #   bind = {
        #     "M-[" = "writeroom-decrease-width";
        #     "M-]" = "writeroom-increase-width";
        #   };
        #   hook = [ "(writeroom-mode . visual-line-mode)" ];
        #   config = ''
        #       (setq writeroom-bottom-divider-width 0)
        #     '';
        # };

        buffer-move = {
          enable = true;
          bind = {
            "C-S-<up>" = "buf-move-up";
            "C-S-<down>" = "buf-move-down";
            "C-S-<left>" = "buf-move-left";
            "C-S-<right>" = "buf-move-right";
          };
        };

        ivy = {
          enable = true;
          demand = true;
          diminish = [ "ivy-mode" ];
          command = [ "ivy-mode" ];
          config = ''
            (setq ivy-use-virtual-buffers t
                  ivy-count-format "%d/%d "
                  ivy-virtual-abbreviate 'full)

            (ivy-mode 1)
          '';
        };

        ivy-hydra = {
          enable = true;
          defer = true;
          after = [ "ivy" "hydra" ];
        };

        ivy-xref = {
          enable = true;
          after = [ "ivy" "xref" ];
          command = [ "ivy-xref-show-xrefs" ];
          config = ''
            (setq xref-show-xrefs-function #'ivy-xref-show-xrefs)
          '';
        };

        swiper = {
          enable = true;
          command = [ "swiper" "swiper-all" "swiper-isearch" ];
          bind = {
            "C-s" = "swiper-isearch";
          };
        };

        # Lets counsel do prioritization. A fork of smex.
        amx = {
          enable = true;
          command = [ "amx-initialize" ];
        };

        counsel = {
          enable = true;
          bind = {
            "C-x C-d" = "counsel-dired-jump";
            "C-x C-f" = "counsel-find-file";
            "C-x C-M-f" = "counsel-fzf";
            "C-x C-r" = "counsel-recentf";
            "C-x C-y" = "counsel-yank-pop";
            "M-x" = "counsel-M-x";
            "C-c g" = "counsel-git-grep";
          };
          diminish = [ "counsel-mode" ];
          config =
            let
              fd = "${pkgs.fd}/bin/fd";
              fzf = "${pkgs.fzf}/bin/fzf";
            in
            ''
              (setq counsel-fzf-cmd "${fd} --type f | ${fzf} -f \"%s\"")
            '';
        };
        hungry-delete = {
          enable = true;
          init = ''
            (eval-when-compile
            ;; Silence missing function warnings
            (declare-function global-hungry-delete-mode "hungry-delete.el"))
          '';
          hook = [
            "(add-hook 'minibuffer-setup-hook (lambda () (hungry-delete-mode -1)))"
          ];

          config = ''
            (global-hungry-delete-mode t)
          '';
        };
        nyan-mode = {
          enable = true;
          command = [ "nyan-mode" ];
          config = ''
            (setq nyan-wavy-trail t)
          '';
        };

        string-inflection = {
          enable = true;
          bind = {
            "C-c C-u" = "string-inflection-all-cycle";
          };
        };
        git-gutter = {
          enable = true;
          init = ''
            (eval-when-compile
            ;; Silence missing function warnings
            (declare-function global-git-gutter-mode "git-gutter.el"))
          '';
          config = ''
            ;; If you enable global minor mode
            (global-git-gutter-mode t)
            ;; Auto update every 5 seconds
            (custom-set-variables
            '(git-gutter:update-interval 5))

            ;; Set the foreground color of modified lines to something obvious
            (set-face-foreground 'git-gutter:modified "purple")
          '';
        };
        # Configure magit, a nice mode for the git SCM.
        magit = {
          enable = true;
          bind = {
            "M-g M-s" = "magit-status";
            "M-g M-c" = "magit-checkout";
          };
          config = ''
            (setq magit-completing-read-function 'ivy-completing-read)
            (add-to-list 'git-commit-style-convention-checks
              'overlong-summary-line)
          '';
        };

        git-messenger = {
          enable = true;
          bind = {
            "C-x v p" = "git-messenger:popup-message";
          };
        };

        multiple-cursors = {
          enable = true;
          bind = {
            #"C-S-c C-S-c" = "mc/edit-lines";
            "C-c m" = "mc/mark-all-like-this";
            "C->" = "mc/mark-next-like-this";
            "C-<" = "mc/mark-previous-like-this";
          };
        };

        nix-sandbox = {
          enable = true;
          command = [ "nix-current-sandbox" "nix-shell-command" ];
        };

        avy = {
          enable = true;
          extraConfig = ''
            :bind* ("C-c SPC" . avy-goto-word-or-subword-1)
          '';
        };

        undo-tree = {
          enable = true;
          demand = true;
          diminish = [ "undo-tree-mode" ];
          command = [ "global-undo-tree-mode" ];
          config = ''
            (setq undo-tree-visualizer-relative-timestamps t
                  undo-tree-visualizer-timestamps t
                  undo-tree-auto-save-history nil)
            (global-undo-tree-mode)
          '';
        };
        origami = {
          enable = true;
          bindLocal = {
            origami-mode-map = {

              "C-c o :" = "origami-recursively-toggle-node";
              "C-c o a" = "origami-toggle-all-nodes";
              "C-c o t" = "origami-toggle-node";
              "C-c o o" = "origami-show-only-node";
              "C-c o u" = "origami-undo";
              "C-c o U" = "origami-redo";
              "C-c o C-r" = "origami-reset";
            };
          };

        };
        # Configure AUCTeX.
        # latex = {
        #   enable = true;
        #   package = epkgs: epkgs.auctex;
        #   mode = [ ''("\\.tex\\'" . latex-mode)'' ];
        #   hook = [
        #     ''
        #     (LaTeX-mode
        #      . (lambda ()
        #          (turn-on-reftex)       ; Hook up AUCTeX with RefTeX.
        #          (auto-fill-mode)
        #          (define-key LaTeX-mode-map [adiaeresis] "\\\"a")))
        #   ''
        #   ];
        #   config = ''
        #   (setq TeX-PDF-mode t
        #         TeX-auto-save t
        #         TeX-parse-self t
        #         TeX-output-view-style '(("^pdf$" "." "evince %o")
        #                                 ( "^ps$" "." "evince %o")
        #                                 ("^dvi$" "." "evince %o")))

        #   ;; Add Glossaries command. See
        #   ;; http://tex.stackexchange.com/a/36914
        #   (eval-after-load "tex"
        #     '(add-to-list
        #       'TeX-command-list
        #       '("Glossaries"
        #         "makeglossaries %s"
        #         TeX-run-command
        #         nil
        #         t
        #         :help "Create glossaries file")))
        # '';
        # };

        company-lsp = {
          enable = true;
          after = [ "company" ];
          command = [ "company-lsp" ];
          config = ''
            (setq company-lsp-enable-snippet t
                  company-lsp-async t
                  company-lsp-cache-candidates 'auto)
          '';
        };

        lsp-haskell = {
          enable = true;
          defer = true;
          hook = [
            ''
              (haskell-mode . (lambda ()
                                (direnv-update-environment)
                                (require 'lsp-haskell)
                                (lsp)))
            ''
          ];

        };

        lsp-ui = {
          enable = true;
          command = [ "lsp-ui-mode" ];
          bind = {
            "C-c r d" = "lsp-ui-doc-show";
            "C-c f s" = "lsp-ui-find-workspace-symbol";
          };
          config = ''
            (setq lsp-ui-sideline-enable t
                  lsp-ui-sideline-show-symbol nil
                  lsp-ui-sideline-show-hover nil
                  lsp-ui-sideline-show-code-actions nil
                  lsp-ui-sideline-update-mode 'point
                  lsp-ui-doc-enable nil)
          '';
        };

        lsp-ui-flycheck = {
          enable = true;
          after = [ "flycheck" "lsp-ui" ];
        };

        lsp-mode = {
          enable = true;
          command = [ "lsp" ];
          bind = {
            "C-c r r" = "lsp-rename";
            "C-c r f" = "lsp-format-buffer";
            "C-c r g" = "lsp-format-region";
            "C-c r a" = "lsp-execute-code-action";
            "C-c f r" = "lsp-find-references";
          };
          config = ''
            (setq lsp-eldoc-render-all nil)
          '';
        };

        lsp-java = {
          enable = true;
          hook = [
            ''
              (java-mode . (lambda ()
                (require 'lsp-java)
                (lsp)))
            ''
          ];
          bindLocal = {
            java-mode-map = {
              "C-c r o" = "lsp-java-organize-imports";
            };
          };
          config = ''
            (setq lsp-java-save-actions-organize-imports nil
                  lsp-java-completion-favorite-static-members
                      '("org.assertj.core.api.Assertions.*"
                        "org.assertj.core.api.Assumptions.*"
                        "org.hamcrest.Matchers.*"
                        "org.junit.Assert.*"
                        "org.junit.Assume.*"
                        "org.junit.jupiter.api.Assertions.*"
                        "org.junit.jupiter.api.Assumptions.*"
                        "org.junit.jupiter.api.DynamicContainer.*"
                        "org.junit.jupiter.api.DynamicTest.*"))
          '';
        };

        lsp-rust = {
          enable = true;
          defer = true;
          hook = [
            ''
              (rust-mode . (lambda ()
                (direnv-update-environment)
                (lsp)))
            ''
          ];
        };

        lsp-treemacs = {
          enable = true;
          after = [ "lsp-mode" "treemacs" ];
        };

        dap-mode = {
          enable = true;
          after = [ "lsp-mode" ];
          command = [ "dap-mode" ];
          config = ''
            (dap-mode t)
          '';
        };

        dap-ui = {
          enable = true;
          after = [ "dap-mode" ];
          command = [ "dap-ui-mode" ];
          config = ''
            (dap-ui-mode t)
          '';
        };

        dap-java = {
          enable = true;
          after = [ "dap-mode" "lsp-java" ];
        };

        #  Setup RefTeX.
        reftex = {
          enable = true;
          defer = true;
          config = ''
            (setq reftex-default-bibliography '("~/research/bibliographies/main.bib")
                  reftex-cite-format 'natbib
                  reftex-plug-into-AUCTeX t)
          '';
        };

        haskell-mode = {
          enable = true;
          mode = [
            ''("\\.hs\\'" . haskell-mode)''
            ''("\\.hsc\\'" . haskell-mode)''
            ''("\\.c2hs\\'" . haskell-mode)''
            ''("\\.cpphs\\'" . haskell-mode)''
            ''("\\.lhs\\'" . haskell-literate-mode)''
          ];
          hook = [
            ''(haskell-mode . interactive-haskell-mode)''
            ''(haskell-mode . subword-mode)''
          ];
          bindLocal = {
            haskell-mode-map = {
              "C-c h i" = "haskell-navigate-imports";
              "C-c r o" = "haskell-mode-format-imports";
              "C-<right>" = "haskell-move-nested-right";
              "C-<left>" = "haskell-move-nested-left";
            };
          };
          config = ''
            (setq tab-width 2)

            (setq haskell-process-log t
                  haskell-notify-p t)

            (setq haskell-process-args-cabal-repl
                  '("--ghc-options=+RTS -M500m -RTS -ferror-spans -fshow-loaded-modules"))
          '';
        };

        haskell-cabal = {
          enable = true;
          mode = [ ''("\\.cabal\\'" . haskell-cabal-mode)'' ];
          bindLocal = {
            haskell-cabal-mode-map = {
              "C-c C-c" = "haskell-process-cabal-build";
              "C-c c" = "haskell-process-cabal";
              "C-c C-b" = "haskell-interactive-bring";
            };
          };
        };

        markdown-mode = {
          enable = true;
          mode = [
            ''"\\.mdwn\\'"''
            ''"\\.markdown\\'"''
            ''"\\.md\\'"''
          ];
          config = ''
            (setq markdown-command "${pkgs.pandoc}/bin/pandoc")
          '';
        };

        pandoc-mode = {
          enable = true;
          after = [ "markdown-mode" ];
          hook = [ "markdown-mode" ];
          bindLocal = {
            markdown-mode-map = {
              "C-c C-c" = "pandoc-run-pandoc";
            };
          };
        };
        pug-mode = {
          enable = true;
        };
        nix-mode = {
          enable = true;
          mode = [ ''"\\.nix\\'"'' ];
          command = [ "org-babel-execute:nix" ];
          hook = [ "(nix-mode . subword-mode)" ];
          config = ''
            :init/defun*
                    (org-babel-execute:nix (body params)
                        "Execute a block of Nix code with org-babel."
                        (message "executing Nix source code block")
                        (let ((E (cdr (assoc :E params)))
                            (in-file (unless E (org-babel-temp-file "n" ".nix")))
                            (show-trace (cdr (assoc :show-trace params)))
                            (json (cdr (assoc :json params)))
                            (xml (cdr (assoc :xml params))))
                        (unless E (with-temp-file in-file (insert body)))
                        (org-babel-eval
                            (format "nix-instantiate --read-write-mode --eval %s %s %s %s"
                                (if show-trace "--show-trace" "")
                                (if json "--json" "")
                                (if xml "--xml" "")
                                (if E (format "-E '%s'" body) (org-babel-process-file-name in-file)))
                        "")))
          '';
        };
        eglot = {
          enable = true;
          config = ''
            (add-to-list 'eglot-server-programs '(nix-mode . ("nil")))
          '';
          hook = [ "(nix-mode . eglot-ensure)" ];
        };
        # Use ripgrep for fast text search in projects. I usually use
        # this through Projectile.
        ripgrep = {
          enable = true;
          command = [ "ripgrep-regexp" ];
        };
        wgrep = {
          enable = true;
        };
        # erc-sasl = {
        #   package = epkgs:
        #     epkgs.trivialBuild {
        #       pname = "erc-sasl.el";
        #       src = pkgs.fetchurl {
        #         url =
        #           "https://gitlab.com/psachin/erc-sasl/-/raw/0fa60fdf8c2c1cdbe048e5189e35e480fe931c20/erc-sasl.el";
        #         sha256 = "sha256-E/kCGlxfrmNwJM8BJ/3DR8l1ypnv++3dAEV7nlCxS5w=";
        #       };
        #       preferLocalBuild = true;
        #       allowSubstitutes = true;
        #     };

        #   enable = true;
        #   after = [ "erc" ];
        #   config = ''
        #     (add-to-list 'erc-sasl-server-regexp-list "irc\\.libera\\.chat")
        #   '';
        # };
        org = {
          enable = true;
          bind = {
            "C-c c" = "org-capture";
            "C-c a" = "org-agenda";
            "C-c l" = "org-store-link";
            "C-c b" = "org-switchb";
          };
          hook = [
            ''
              (org-mode
                . (lambda ()
                  (add-hook 'completion-at-point-functions
                            'pcomplete-completions-at-point nil t)))
            ''
          ];
          config = ''
            ;; Some general stuff.
            (setq org-reverse-note-order t
                  org-use-fast-todo-selection t
                  org-adapt-indentation t
                  org-ellipsis " ⏴")

            ;; html export stuff
            (setq custom-html-preamble "
              <ul>
                <li><a href=\"./index.html\">Home</a></li>
              </ul>
              <div id=\"toc\"></div>
            ")
            ;; Change the `author' here.
            (setq custom-html-postamble "
              <p class=\"author\">Taylor</p>

              <!-- Initialize Custom Styling JS -->
              <script src=\"./js/styling.js\"></script>
            ")

            (setq org-html-postamble t)

            (setq org-html-preamble-format `(("en" ,custom-html-preamble)))

            (setq org-html-postamble-format `(("en" ,custom-html-postamble)))
            (setq org-publish-project-alist
            '(

              ;; ... add all the components here (see below)...
              ("org-notes"
                :base-directory "~/org/"
                :base-extension "org"
                :publishing-directory "~/org/out/"
                :recursive t
                :publishing-function org-html-publish-to-html
                :headline-levels 1             ; Just the default for this project.
                :auto-preamble t
              )
              ("org-work"
                :base-directory "~/src/org/"
                :base-extension "org"
                :publishing-directory "~/src/org/out/"
                :recursive t
                :publishing-function org-html-publish-to-html
                :headline-levels 1             ; Just the default for this project.
                :auto-preamble t
              )

              ("org-static"
                :base-directory "~/org/"
                :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf"
                :publishing-directory "~/org/out/"
                :recursive t
                :publishing-function org-publish-attachment
              )
              ("org" :components ("org-notes" "org-static"))
            ))


            ;; FIXME, setup rah-org replacement
            (setq org-tag-alist '((:startgroup . nil)
                        ("@tgunnoe" . ?j)
                        (:endgroup . nil)
                        (:startgroup . nil)
                        ("!v0" . ?0) ("!v1" . ?1)
                        (:endgroup . nil)
                        ("bitcoin") ("emacs") ("linux") ("books") ("gaming")
                        ("programming") ("free software") ("open hardware")
                        ("research") ("study") ("review") ("code") ("design")
                        ("exercise") ("meet")))

            ;; Refiling should include not only the current org buffer but
            ;; also the standard org files. Further, set up the refiling to
            ;; be convenient with IDO. Follows norang's setup quite closely.
            (setq org-refile-targets '((nil :maxlevel . 2)
              (org-agenda-files :maxlevel . 2))
                  org-refile-use-outline-path t
                  org-outline-path-complete-in-steps nil
                  org-refile-allow-creating-parent-nodes 'confirm)

            ;; Add some todo keywords.
            (setq org-todo-keywords
                  '((sequence "TODO(t)"
                              "INPROGRESS(i!)"
                              "WAITING(w@/!)"
                              "DELEGATED(@!)"
                              "|"
                              "DONE(d!)"
                              "CANCELED(c@!)")))

            ;; Setup org capture.
            (setq org-default-notes-file (concat org-directory "/inbox.org"))

            ;; Active Org-babel languages
            (org-babel-do-load-languages 'org-babel-load-languages
              '((plantuml . t)
                (http . t)
                (python . t)
                (shell . t)
                (sql . t)
                (verb . t)))

            ;; Unfortunately org-mode tends to take over keybindings that
            ;; start with C-c.
            (unbind-key "C-c SPC" org-mode-map)
            (unbind-key "C-c w" org-mode-map)
          '';
        };
        org-roam = {
          enable = true;
          after = [ "org" ];
          bind = {
            "C-c n l" = "org-roam-buffer-toggle";
            "C-c n f" = "org-roam-node-find";
            "C-c n i" = "org-roam-node-insert";
          };
          config = ''
            (org-roam-setup)
          '';
        };
        elpher = {
          enable = true;
        };
        # ox-slimhtml = {
        #   enable = true;
        #   after = [ "org" ];
        #   config = ''
        #          (org-export-define-derived-backend 'custom-html-exporter
        #              'slimhtml                             ;; org's default exporter is 'html
        #              :translate-alist
        #              '((bold . ox-slimhtml-bold)           ;; technically, this is already set
        #              (special-block . org-html-special-block)))

        #   '';
        # };
        toc-org = {
          enable = true;
          after = [ "org" ];
        };
        org-agenda = {
          enable = true;
          after = [ "org" ];
          defer = true;
          config = ''
            ;; Set up agenda view.
            (setq org-agenda-files
              (list
                "~/org/inbox.org"
                "~/org/gtd.org"
                "~/org/tickler.org"
                "~/org/iohk/tasks.org")

                  org-deadline-warning-days 14
                  org-agenda-show-all-dates t
                  org-agenda-skip-deadline-if-done t
                  org-agenda-skip-scheduled-if-done t
                  org-agenda-start-on-weekday nil)
          '';
        };

        org-mobile = {
          enable = true;
          after = [ "org" ];
          defer = true;
        };

        ob-http = {
          enable = true;
          after = [ "org" ];
          defer = true;
        };

        ob-plantuml = {
          enable = true;
          after = [ "org" ];
          defer = true;
        };
        ob-verb = {
          enable = true;
          after = [ "org" ];
          defer = true;
        };
        org-table = {
          enable = true;
          after = [ "org" ];
          command = [ "orgtbl-to-generic" ];
          hook = [
            # For orgtbl mode, add a radio table translator function for
            # taking a table to a psql internal variable.
            ''
              (orgtbl-mode
                . (lambda ()
                  (defun rah-orgtbl-to-psqlvar (table params)
                    "Converts an org table to an SQL list inside a psql internal variable"
                    (let* ((params2
                              (list
                                :tstart (concat "\\set " (plist-get params :var-name) " '(")
                                :tend ")'"
                                :lstart "("
                                :lend "),"
                                :sep ","
                                :hline ""))
                              (res (orgtbl-to-generic table (org-combine-plists params2 params))))
                          (replace-regexp-in-string ",)'$"
                    ")'"
                    (replace-regexp-in-string "\n" "" res))))))
            ''
          ];
          config = ''
            (unbind-key "C-c SPC" orgtbl-mode-map)
            (unbind-key "C-c w" orgtbl-mode-map)
          '';
          extraConfig = ''
            :functions org-combine-plists
          '';
        };

        org-capture = {
          enable = true;
          after = [ "org" ];
          config = ''
            (setq org-capture-templates '(("t" "Todo [inbox]" entry
                                          (file+headline "~/org/inbox.org" "Tasks")
                                          "* TODO %i%?")
                                          ("T" "Tickler" entry
                                          (file+headline "~/org/tickler.org" "Tickler")
                                          "* %i%? \n %U")))
          '';
        };

        org-clock = {
          enable = true;
          after = [ "org" ];
          config = ''
            (setq org-clock-rounding-minutes 5
                  org-clock-out-remove-zero-time-clocks t)
          '';
        };

        org-duration = {
          enable = true;
          after = [ "org" ];
          config = ''
            ;; I always want clock tables and such to be in hours, not days.
            (setq org-duration-format (quote h:mm))
          '';
        };

        org-bullets = {
          enable = true;
          hook = [ "(org-mode . org-bullets-mode)" ];
        };
        org-present = {
          enable = true;
          hook = [
            "('org-present-mode-hook 'my/org-present-start)"
            "('org-present-mode-quit-hook 'my/org-present-end)"
          ];
        };
        visual-fill-column = {
          enable = true;
          config = ''
            (setq visual-fill-column-center-text t
                  visual-fill-column-width 110)
          '';
        };
        org-tree-slide = {
          enable = true;
          command = [ "org-tree-slide-mode" ];
        };
        #        presentation-mode = {
        #          enable = true;
        # Set up yasnippet. Defer it for a while since I don't generally
        # need it immediately.
        yasnippet = {
          enable = true;
          defer = 1;
          diminish = [ "yas-minor-mode" ];
          command = [ "yas-global-mode" "yas-minor-mode" ];
          hook = [
            # Yasnippet interferes with tab completion in ansi-term.
            "(term-mode . (lambda () (yas-minor-mode -1)))"
          ];
          config = "(yas-global-mode 1)";
        };

        # Doesn't seem to work, complains about # in go snippets.
        yasnippet-snippets = {
          enable = false;
          after = [ "yasnippet" ];
        };

        # Setup the cperl-mode, which I prefer over the default Perl
        # mode.
        cperl-mode = {
          enable = true;
          defer = true;
          hook = [ "ggtags-mode" ];
          command = [ "cperl-set-style" ];
          config = ''
            ;; Avoid deep indentation when putting function across several
            ;; lines.
            (setq cperl-indent-parens-as-block t)

            ;; Use cperl-mode instead of the default perl-mode
            (defalias 'perl-mode 'cperl-mode)
            (cperl-set-style "PerlStyle")
          '';
        };

        # Setup ebib, my chosen bibliography manager.
        ebib = {
          enable = true;
          command = [ "ebib" ];
          hook = [
            # Highlighting of trailing whitespace is a bit annoying in ebib.
            ''(ebib-index-mode-hook . rah-disable-trailing-whitespace-mode)''
            ''(ebib-entry-mode-hook . rah-disable-trailing-whitespace-mode)''
          ];
          config = ''
            (setq ebib-latex-preamble '("\\usepackage{a4}"
                                        "\\bibliographystyle{amsplain}")
                  ebib-print-preamble '("\\usepackage{a4}")
                  ebib-print-tempfile "/tmp/ebib.tex"
                  ebib-extra-fields '(crossref
                                      url
                                      annote
                                      abstract
                                      keywords
                                      file
                                      timestamp
                                      doi))
          '';
        };
        simple-mpc = {
          enable = true;
        };
        smartparens = {
          enable = true;
          defer = 1;
          diminish = [ "smartparens-mode" ];
          command = [ "smartparens-global-mode" "show-smartparens-global-mode" ];
          bindLocal = {
            smartparens-mode-map = {
              "C-M-f" = "sp-forward-sexp";
              "C-M-b" = "sp-backward-sexp";
            };
          };
          config = ''
            (require 'smartparens-config)
            (smartparens-global-mode t)
            (show-smartparens-global-mode t)
          '';
        };

        fill-column-indicator = {
          enable = true;
          command = [ "fci-mode" ];
          defer = 1;
        };

        flycheck = {
          enable = true;
          diminish = [ "flycheck-mode" ];
          command = [ "global-flycheck-mode" ];
          defer = 1;
          bind = {
            "M-n" = "flycheck-next-error";
            "M-p" = "flycheck-previous-error";
          };
          config = ''
            ;; Only check buffer when mode is enabled or buffer is saved.
            (setq flycheck-check-syntax-automatically '(mode-enabled save))

            ;; Enable flycheck in all eligible buffers.
            (global-flycheck-mode)
          '';
        };

        flycheck-plantuml = {
          enable = true;
          hook = [ "(flycheck-mode . flycheck-plantuml-setup)" ];
        };

        projectile = {
          enable = true;
          diminish = [ "projectile-mode" ];
          command = [ "projectile-mode" ];
          bindKeyMap = {
            "C-c p" = "projectile-command-map";
          };
          config = ''
            (setq projectile-enable-caching t
                  projectile-completion-system 'ivy)
            (projectile-mode 1)
          '';
        };

        plantuml-mode = {
          enable = true;
          mode = [ ''"\\.puml\\'"'' ];
        };

        ace-window = {
          enable = true;
          extraConfig = ''
            :bind* (("C-c w" . ace-window)
                    ("M-o" . ace-window))
          '';
        };

        company = {
          enable = true;
          diminish = [ "company-mode" ];
          hook = [ "(after-init . global-company-mode)" ];
          extraConfig = ''
            :bind (:map company-mode-map
                        ([remap completion-at-point] . company-complete-common)
                        ([remap complete-symbol] . company-complete-common))
          '';
          config = ''
            (setq company-idle-delay 0.3
                  company-show-numbers t)
          '';
        };

        company-yasnippet = {
          enable = true;
          bind = {
            "M-/" = "company-yasnippet";
          };
        };

        company-dabbrev = {
          enable = true;
          after = [ "company" ];
          command = [ "company-dabbrev" ];
          config = ''
            (setq company-dabbrev-downcase nil
                  company-dabbrev-ignore-case t)
          '';
        };

        company-quickhelp = {
          enable = true;
          after = [ "company" ];
          command = [ "company-quickhelp-mode" ];
          config = ''
            (company-quickhelp-mode 1)
          '';
        };

        company-cabal = {
          enable = true;
          after = [ "company" ];
          command = [ "company-cabal" ];
          config = ''
            (add-to-list 'company-backends 'company-cabal)
          '';
        };
        company-go = {
          enable = true;
          after = [ "company" ];
          command = [ "company-go" ];
          config = ''
            (add-to-list 'company-backends 'company-go)
          '';
        };
        company-restclient = {
          enable = true;
          after = [ "company" "restclient" ];
          command = [ "company-restclient" ];
          config = ''
            (add-to-list 'company-backends 'company-restclient)
          '';
        };

        #php-mode = {
        #  enable = true;
        #  mode = [ ''"\\.php\\'"'' ];
        #  hook = [ "ggtags-mode" ];
        #};

        protobuf-mode = {
          enable = true;
          mode = [ ''"'\\.proto\\'"'' ];
        };

        python = {
          enable = true;
          mode = [ ''("\\.py\\'" . python-mode)'' ];
          hook = [ "ggtags-mode" ];
        };
        rudel = {
          #enable = true;
        };
        restclient = {
          enable = true;
          mode = [ ''("\\.http\\'" . restclient-mode)'' ];
        };

        transpose-frame = {
          enable = true;
          bind = {
            "C-c f t" = "transpose-frame";
          };
        };

        tt-mode = {
          enable = true;
          mode = [ ''"\\.tt\\'"'' ];
        };

        smart-tabs-mode = {
          enable = false;
          config = ''
            (smart-tabs-insinuate 'c 'c++ 'cperl 'java)
          '';
        };

        octave = {
          enable = true;
          mode = [
            ''("\\.m\\'" . octave-mode)''
          ];
        };

        yaml-mode = {
          enable = true;
          mode = [ ''"\\.yaml\\'"'' ];
        };

        wc-mode = {
          enable = true;
          command = [ "wc-mode" ];
        };

        web-mode = {
          enable = true;
          mode = [
            ''"\\.html\\'"''
            ''"\\.jsx?\\'"''
          ];
          config = ''
            (setq web-mode-attr-indent-offset 4
                  web-mode-code-indent-offset 2
                  web-mode-markup-indent-offset 2)

            (add-to-list 'web-mode-content-types '("jsx" . "\\.jsx?\\'"))
          '';
        };

        dired = {
          enable = true;
          defer = true;
          config = ''
            (put 'dired-find-alternate-file 'disabled nil)
            ;; Use the system trash can.
            (setq delete-by-moving-to-trash t)
          '';
        };

        wdired = {
          enable = true;
          bindLocal = {
            dired-mode-map = {
              "C-c C-w" = "wdired-change-to-wdired-mode";
            };
          };
          config = ''
            ;; I use wdired quite often and this setting allows editing file
            ;; permissions as well.
            (setq wdired-allow-to-change-permissions t)
          '';
        };

        dired-x = {
          enable = true;
          after = [ "dired" ];
        };

        recentf = {
          enable = true;
          command = [ "recentf-mode" ];
          config = ''
            (setq recentf-save-file (locate-user-emacs-file "recentf")
                  recentf-max-menu-items 20
                  recentf-max-saved-items 500
                  recentf-exclude '("COMMIT_MSG" "COMMIT_EDITMSG"))
          '';
        };

        nxml-mode = {
          enable = true;
          mode = [ ''"\\.xml\\'"'' ];
          config = ''
            (setq nxml-child-indent 2
                  nxml-attribute-indent 4
                  nxml-slash-auto-complete-flag t)
            (add-to-list 'rng-schema-locating-files
              "~/.emacs.d/nxml-schemas/schemas.xml")
          '';
        };

        rust-mode = {
          enable = true;
          mode = [ ''"\\.rs\\'"'' ];
        };
        tide = {
          enable = true;
          mode = [ ''"\\.rs\\'"'' ];
        };
        sendmail = {
          enable = false;
          mode = [
            ''("mutt-" . mail-mode)''
            ''("\\.article" . mail-mode))''
          ];
          hook = [
            ''
              (lambda ()
                    (auto-fill-mode)     ; Avoid having to M-q all the time.
                    (rah-mail-flyspell)  ; I spel funily soemtijms.
                    (rah-mail-reftex)    ; Make it easy to include references.
                    (mail-text))         ; Jump to the actual text.
            ''
          ];
        };

        systemd = {
          enable = true;
          defer = true;
        };

        treemacs = {
          enable = true;
          bind = {
            "C-c t f" = "treemacs-find-file";
            "C-c t t" = "treemacs";
          };
        };
        powerline = {
          enable = true;
          config = ''
            (defun powerline-right-theme ()
            "Setup a mode-line with major and minor modes on the right side."
            (interactive)
            (setq-default mode-line-format
                          '("%e"
                            (:eval
                            (let* ((active (powerline-selected-window-active))
                                    (mode-line-buffer-id (if active 'mode-line-buffer-id 'mode-line-buffer-id-inactive))
                                    (mode-line (if active 'mode-line 'mode-line-inactive))
                                    (face0 (if active 'powerline-active0 'powerline-inactive0))
                                    (face1 (if active 'powerline-active1 'powerline-inactive1))
                                    (face2 (if active 'powerline-active2 'powerline-inactive2))
                                    (separator-left (intern (format "powerline-%s-%s"
                                                                    (powerline-current-separator)
                                                                    (car powerline-default-separator-dir))))
                                    (separator-right (intern (format "powerline-%s-%s"
                                                                      (powerline-current-separator)
                                                                      (cdr powerline-default-separator-dir))))
                                    (lhs (list (powerline-raw "%*" face0 'l)
                                                (powerline-buffer-size face0 'l)
                                                (powerline-buffer-id `(mode-line-buffer-id ,face0) 'l)
                                                (powerline-raw " ")
                                                (funcall separator-left face0 face1)
                                                (powerline-narrow face1 'l)
                                                (powerline-vc face1)))
                                    (center (list (powerline-raw global-mode-string face1 'r)
                                                  (powerline-raw "%4l" face1 'r)
                                                  (powerline-raw ":" face1)
                                                  (powerline-raw "%3c" face1 'r)
                                                  (funcall separator-right face1 face0)
                                                  (powerline-raw " ")
                                                  (powerline-raw "%6p" face0 'r)
                                                  (powerline-hud face2 face1)
                                                  ))
                                    (rhs (list (powerline-raw " " face1)
                                                (funcall separator-left face1 face2)
                                                (when (and (boundp 'erc-track-minor-mode) erc-track-minor-mode)
                                                  (powerline-raw erc-modified-channels-object face2 'l))
                                                (powerline-major-mode face2 'l)
                                                (powerline-process face2)
                                                (powerline-raw " :" face2)
                                                (powerline-minor-modes face2 'l)
                                                (powerline-raw " " face2)
                                                (funcall separator-right face2 face1)
                                                ))
                                    )
                                (concat (powerline-render lhs)
                                        (powerline-fill-center face1 (/ (powerline-width center) 2.0))
                                        (powerline-render center)
                                        (powerline-fill face1 (powerline-width rhs))
                                        (powerline-render rhs)))))))
            (powerline-right-theme)
          '';
        };
        scala-mode = {
          enable = true;
          mode = [ ''"\\.scala\\'"'' ];
        };
        treemacs-projectile = {
          enable = true;
          after = [ "treemacs" "projectile" ];
        };

        verb = {
          enable = true;
          defer = true;
          after = [ "org" ];
          config = ''
            (define-key org-mode-map (kbd "C-c C-r") verb-command-map)
            (setq verb-trim-body-end "[ \t\n\r]+")
          '';
        };

        vterm = {
          enable = true;
          command = [ "vterm" ];
          hook = [ "(vterm-mode . rah-disable-trailing-whitespace-mode)" ];
          config = ''
            (setq vterm-kill-buffer-on-exit t
                  vterm-max-scrollback 10000)
          '';
        };
      };
    };
  };
}
