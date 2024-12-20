;;; test/ert.el --- Run ert tests  -*- lexical-binding: t; -*-

;;; Commentary:
;;
;; Command to run ert tests,
;;
;;   $ eask ert [files..]
;;
;;
;;  Positionals:
;;
;;    [files..]     specify files to run ert tests
;;

;;; Code:

(let ((dir (file-name-directory (nth 1 (member "-scriptload" command-line-args)))))
  (load (expand-file-name "_prepare.el"
                          (locate-dominating-file dir "_prepare.el"))
        nil t))

(require 'ert)

(defvar eask-test-ert--message-loop nil
  "Prevent inifinite recursive message function.")

(defun eask-test-ert--message (fnc &rest args)
  "Colorized ert messages.

Arguments FNC and ARGS are used for advice `:around'."
  (if eask-test-ert--message-loop (apply fnc args)
    (let ((eask-test-ert--message-loop t))
      (cond
       ;; (message nil) is used to clear the minibuffer
       ;; However, format requires the first argument to be a format string
       ((null (car args))
        (apply fnc args))
       ((string-match-p "^[ ]+FAILED " (apply #'format args))
        (eask-msg (ansi-red (apply #'format args))))
       ((string-match-p "^[ ]+SKIPPED " (apply #'format args))
        (eask-msg (ansi-white (apply #'format args))))
       ((string-match-p "^[ ]+passed " (apply #'format args))
        (eask-msg (ansi-green (apply #'format args))))
       (t (apply fnc args))))))

(advice-add 'message :around #'eask-test-ert--message)

(eask-start
  (let* ((patterns (eask-args))
         (files (eask-expand-file-specs patterns)))
    (cond
     ;; Files found, do the action!
     (files
      (eask-pkg-init)
      (eask-ignore-errors
        (mapc #'load-file files)
        (ert-run-tests-batch-and-exit)))
     ;; Pattern defined, but no file found!
     (patterns
      (eask-info "(No files match wildcard: %s)"
                 (mapconcat #'identity patterns " ")))
     ;; Default, print help!
     (t
      (eask-info "(No tests found.)")
      (eask-help "test/ert")))))

;;; test/ert.el ends here
