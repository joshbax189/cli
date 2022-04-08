;;; exec.el --- Execute command with correct load-path set up  -*- lexical-binding: t; -*-

;;; Commentary:
;;
;; Execute command with correct load-path set up
;;
;;   $ eask exec [args..]
;;
;;
;;  Initialization options:
;;
;;    [args..]     execute command with correct load-path set up
;;

;;; Code:

(load (expand-file-name
       "../_prepare.el"
       (file-name-directory (nth 1 (member "-scriptload" command-line-args))))
      nil t)

(defun eask--help-exec ()
  "Print help if command failed."
  (eask-msg "")
  (eask-msg "💡 You would need to specify the program name in order to make execution!")
  (eask-msg "")
  (eask-msg "    $ eask exec [program] [options..]")
  (eask-msg ""))

(defun eask--shell-command (command)
  "Wrap `shell-command' with better output to terminal."
  (eask-info "Executing command: %s..." command)
  (let ((code (shell-command command "*output*" "*error*")))
    (if (zerop code)
        (eask-with-verbosity 'debug
          (with-current-buffer "*output*" (eask-msg (buffer-string))))
      (with-current-buffer "*error*" (eask-msg (ansi-red (buffer-string))))
      (error "Error from the execution, exit code %s" code))))

(eask-start
  (eask-pkg-init)
  ;; XXX This is the hack by adding all `bin' folders from local elpa.
  (eask-setup-paths)
  (setq commander-args (cddr argv))  ; by pass `--' as well
  (if-let ((name (eask-argv 1)))
      (or
       ;; 1) Execute executable if found
       (let ((program (executable-find name))) (ignore-errors (load program t t)))
       ;; 2) Execute `commander' (ert-runner, github-elpa, and elsa, etc)
       (let ((el (locate-library name))) (ignore-errors (load el t t)))
       ;; 3) Execute `shell-command'
       ;;
       ;; TODO `shell-command' would jump out of Emacs and does not share the
       ;; same environment PATH.
       (let ((command (mapconcat #'identity (append (list name) commander-args) " ")))
         (eask--shell-command command)))
    (eask-info "✗ (No exeuction output)")
    (eask--help-exec)))

;;; exec.el ends here