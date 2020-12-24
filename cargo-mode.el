;;; cargo-mode.el --- A mode for Cargo configuration files. -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

(require 'dash)
(require 'flycheck)
(require 'toml-mode)

(define-derived-mode cargo-mode toml-mode "Cargo"
  "Major mode for Cargo.toml files."
  )

;; Order matters for chained checkers?
(add-to-list 'flycheck-checkers 'cargo-upgrade)
(add-to-list 'flycheck-checkers 'cargo)

(add-to-list 'auto-mode-alist '("Cargo\\.toml\\'" . cargo-mode))

(flycheck-define-checker cargo
  "Cargo checker."
  :command ("cargo" "metadata" "--format-version" "1" "--no-deps")
  :error-patterns
  ((error "error: " (message) " at `" (file-name) "`\n"
          (one-or-more
           "\nCaused by:\n"
           "  " (or (seq (message) " at line " line " column " column)
                    (message)) "\n")))
  ;; Most cargo errors don't have line numbers.
  :error-filter flycheck-fill-empty-line-numbers
  :next-checkers ((warning . cargo-upgrade))
  :modes cargo-mode
  :standard-input nil)

(flycheck-define-checker cargo-upgrade
  "Cargo upgrade checker."
  ;; TODO: make sure it's installed
  :command ("cargo" "upgrade" "--dry-run")
  :error-parser flycheck-parse-with-patterns-without-color
  :error-patterns
  ((info line-start (one-or-more " ") "Upgrading " (message) line-end))
  ;; TODO: remap crate to line
  :error-filter flycheck-fill-empty-line-numbers
  :modes cargo-mode
  :standard-input nil)

(provide 'cargo-mode)

;;; cargo-mode.el ends here
