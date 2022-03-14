;;; _prepare.el --- Prepare for command tasks  -*- lexical-binding: t; -*-
;;; Commentary: Utility module to make Eask work
;;; Code:

(require 'package)
(require 'subr-x)

(defun eask--flag (name)
  "Return flag NAME exists."
  (member (concat "--eask" name) argv))

(defun eask-global-p ()
  "Return non-nil if [global] flag is enabled."
  (eask--flag "-g"))

(defun eask-force-p ()
  "Return non-nil if [force] flag is enabled."
  (eask--flag "-f"))

(defmacro eask-start (&rest body)
  "Execute BODY with workspace setup."
  (declare (indent 0) (debug t))
  ;; set it locally, else we ignore to respect default settings
  `(if-let ((_ (not (eask-global-p)))
            (user-emacs-directory (expand-file-name ".eask/"))
            (package-user-dir (expand-file-name "elpa" user-emacs-directory))
            (user-init-file (locate-user-emacs-file "init.el"))
            (custom-file (locate-user-emacs-file "custom.el"))
            (eask-file (expand-file-name "../Eask" user-emacs-directory)))
       (progn
         (ignore-errors (make-directory package-user-dir t))
         (ignore-errors (load-file eask-file))
         ,@body)
     ,@body))

;;; _prepare.el ends here
