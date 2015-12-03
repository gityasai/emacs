;;load-path
(defun add-to-load-path (&rest paths)
  (let (path)
		(dolist (path paths paths)
		  (let ((default-directory
				  (expand-file-name (concat user-emacs-directory path))))
			(add-to-list 'load-path default-directory)
			(if (fboundp 'normal-top-level-add-subdirs-to-load-path)
				(normal-top-level-add-subdirs-to-load-path))))))
;;load-path add
(add-to-load-path "elisp" "conf" "public_repos")

(require 'init-loader)
(init-loader-load "~/.emacs.d/conf")

;;キーバインド
(keyboard-translate ?\C-h ?\C-?)

;;ファイル名の設定
(when (eq system-type 'darwin)
  (require 'ucs-normalize)
  (set-file-name-coding-system 'utf-8-hfs)
  (setq locale-coding-system 'utf-8-hfs))

;;行番号とカラム番号を表示
(column-number-mode t)
(line-number-mode t)

;;auto-installの設定
(when (require 'auto-install nil t)
  (setq auto-install-directory "~/.emacs.d/elisp/")
  (auto-install-update-emacswiki-package-name t)
  (auto-install-compatibility-setup))

;;redo+
(when (require 'redo+ nil t)
  (global-set-key (kbd "C-'") 'redo))

;;anything
(when (require 'anything nil t)
  (setq
   anything-idle-delay 0.3
   anything-input-idle-delay 0.2
   anything-candidate-number-limit 100
   anithing-quick-update t
   anything-enable-shortcuts 'alphabet)
  (when (require 'anything-config nil t)
    (setq anything-su-or-sudo "sudo"))
  (require 'anything-match-plugin nil t)
  (when (and (executable-find "cmigemo")
	     (require 'migemo nil t))
    (require 'anything-migemo nil t))
  (when (require 'anything-complete nil t)
    (anything-lisp-complete-symbol-set-timer 150))
  (require 'anything-show-completion nil t)
  (when (require 'auto-install nil t)
    (require 'anything-auto-install nil t))
  (when (require 'auto-install nil t)
    (require 'anything-auto-install nil t))
  (when (require 'descbinds-anything nil t)
    (descbinds-anything-install)))

;;moccur
(when (require 'anything-c-moccur nil t)
  (setq
   anything-c-moccur-anything-idle-delay 0.1
   anything-c-moccur-higligt-info-line-flag t
   anything-c-moccur-enable-auto-look-flag t
   anything-c-moccur-enable-initial-pattern t)
  (global-set-key (kbd "C-M-o") 'anything-c-moccur-occur-by-moccur))

;;auto-complete
(when (require 'auto-complete-config nil t)
  (add-to-list 'ac-dictionary-directories
	       "~/.emacs.d/elisp/ac-dict")
  (define-key ac-mode-map (kbd "M-TAB") 'auto-complete)
  (ac-config-default))


;;elscreen
(when (require 'elscreen nil t)
  (if window-system
      (define-key elscreen-map (kbd "C-z") 'iconify-or-deiconify-frame)
    (define-key elscreen-map (kbd "C-z") 'suspend-emacs)))
(elscreen-start)

;;howm
(setq howm-directory (concat user-emacs-directory "howm"))
(setq howm-menu-lang 'ja)
(when (require 'howm-mode nil t)
  (define-key global-map (kbd "C-c ,,") 'howm-menu))
;;(defun howm-save-buffer-and-kill ()
;;  (interactive)
;;  (when (and (buffer-file-name)
;;	     (string-match "\\.howm" (buffer-file-name)))
;;    (save-buffer)
;;    (kill-buffer nil)))
;;(define-key howm-mode-map (kbd "C-c C-c") 'howm-save-buffer-and-kill)

;;短形編集のためのcua-mode設定
(cua-mode t)
(setq cua-enable-cua-keys nil)

;;php
(when (require 'php-mode nil t)
  (add-to-list 'auto-mode-alist '("\\.ctp\\'" . php-mode))
  (setq php-search-url "http://jp.php.net/ja/")
  (setq php-manual-url "http://jp.php.net/manual/ja/"))

(defun php-indent-hook ()
  (setq indent-tabs-mode nil)
  (setq c-basic-offset 4)
  ;; (c-set-offset 'case-label '+) ; switch文のcaseラベル
  (c-set-offset 'arglist-intro '+) ; 配列の最初の要素が改行した場合
  (c-set-offset 'arglist-close 0)) ; 配列の閉じ括弧

(defun php-completion-hook ()
  (when (require 'php-completion nil t)
    (php-completion-mode t)
    (define-key php-mode-map (kbd "C-o") 'phpcmp-complete)

    (when (require 'auto-complete nil t)
    (make-variable-buffer-local 'ac-sources)
    (add-to-list 'ac-sources 'ac-source-php-completion)
    (auto-complete-mode t))))

(add-hook 'php-mode-hook 'php-completion-hook)

;;gtags
(setq gtags-prefix-key "\C-c")
(setq gtags-suggested-key-mapping t)
(require 'gtags nil t)
(require 'ctags nil t)
(setq tags-revert-without-query t)
;; ctagsを呼び出すコマンドライン。パスが通っていればフルパスでなくてもよい
;; etags互換タグを利用する場合はコメントを外す
;; (setq ctags-command "ctags -e -R ")
;; anything-exuberant-ctags.elを利用しない場合はコメントアウトする
(setq ctags-command "ctags -R --fields=\"+afikKlmnsSzt\" ")
(global-set-key (kbd "<f5>") 'ctags-create-or-update-tags-table)
;; AnythingからTAGSを利用しやすくするコマンド作成
(when (and (require 'anything-exuberant-ctags nil t)
           (require 'anything-gtags nil t))
  ;; anything-for-tags用のソースを定義
  (setq anything-for-tags
        (list anything-c-source-imenu
              anything-c-source-gtags-select
              ;; etagsを利用する場合はコメントを外す
              ;; anything-c-source-etags-select
              anything-c-source-exuberant-ctags-select
              ))

  ;; anything-for-tagsコマンドを作成
  (defun anything-for-tags ()
    "Preconfigured `anything' for anything-for-tags."
    (interactive)
    (anything anything-for-tags
              (thing-at-point 'symbol)
              nil nil nil "*anything for tags*"))

  ;; M-tにanything-for-currentを割り当て
  (define-key global-map (kbd "M-t") 'anything-for-tags))
(setq gtags-mode-hook
      '(lambda ()
         (local-set-key "\M-r" 'gtags-find-rtag)
         (local-set-key "\M-s" 'gtags-find-symbol)
         (local-set-key "\C-t" 'gtags-pop-stack)
         ))

;;flymake
(when (require 'flymake nil t)
  (global-set-key "\C-cd" 'flymake-display-err-menu-for-current-line)
  ;; PHP
  (when (not (fboundp 'flymake-php-init))
    (defun flymake-php-init ()
      (let* ((temp-file (flymake-init-create-temp-buffer-copy
                         'flymake-create-temp-inplace))
             (local-file (file-relative-name
                          temp-file
                          (file-name-directory buffer-file-name))))
        (list "php" (list "-f" local-file "-l"))))
    (setq flymake-allowed-file-name-masks
          (append
           flymake-allowed-file-name-masks
           '(("\.php[345]?$" flymake-php-init))))
    (setq flymake-err-line-patterns
          (cons
           '("\(\(?:Parse error\|Fatal error\|Warning\): .*\) in \(.*\) on line \([0-9]+\)" 2 3 nil 1)
           flymake-err-line-patterns)))
  ;; JavaScript
  (when (not (fboundp 'flymake-javascript-init))
    (defun flymake-javascript-init ()
      (let* ((temp-file (flymake-init-create-temp-buffer-copy
                         'flymake-create-temp-inplace))
             (local-file (file-relative-name
                          temp-file
                          (file-name-directory buffer-file-name))))
        (list "/usr/local/bin/jsl" (list "-process" local-file))))
    (setq flymake-allowed-file-name-masks
          (append
           flymake-allowed-file-name-masks
           '(("\.json$" flymake-javascript-init)
             ("\.js$" flymake-javascript-init))))
    (setq flymake-err-line-patterns
          (cons
           '("\(.+\)(\([0-9]+\)): \(?:lint \)?\(\(?:Warning\|SyntaxError\):.+\)" 1 2 nil 3)
           flymake-err-line-patterns)))
  ;; Ruby
  (when (not (fboundp 'flymake-ruby-init))
    (defun flymake-ruby-init ()
      (let* ((temp-file (flymake-init-create-temp-buffer-copy
                         'flymake-create-temp-inplace))
             (local-file (file-relative-name
                          temp-file
                          (file-name-directory buffer-file-name))))
        '("ruby" '("-c" local-file)))))
  (add-hook 'php-mode-hook
            '(lambda () (flymake-mode t)))
  (add-hook 'js-mode-hook
            (lambda () (flymake-mode t)))
  (add-hook 'ruby-mode-hook
            (lambda () (flymake-mode t))))

;;backup自動保存 無効
(setq make-backup-files nil)
(setq auto-save-default nil)
