;;; lint.el --- Lint the package using `package-lint'  -*- lexical-binding: t; -*-

;;; Commentary:
;;
;; Command use to lint current Emacs package,
;;
;;   $ eask lint [names..]
;;
;;
;;  Initialization options:
;;
;;    [names..]     specify files to byte-compile
;;

;;; Code:

(load-file (expand-file-name
            "_prepare.el"
            (file-name-directory (nth 1 (member "-scriptload" command-line-args)))))

(eask-start
  (eask-package-install 'package-lint)
  (dolist (el (or (eask-argv) (eask-package-el-files)))
    (message "")
    (message "`%s` with package-lint" el)
    (with-temp-buffer
      (emacs-lisp-mode)
      (insert-file-contents el)
      (package-lint-current-buffer))
    (with-current-buffer "*Package-Lint*" (message "%s" (buffer-string)))))

;;; lint.el ends here
