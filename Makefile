.PHONY: pull-linter lint

MARKDOWN_LINTER := wpengine/mdl

pull-linters: ## Pull all used linter images
	docker pull ${MARKDOWN_LINTER}

lint: pull-linters  ## Run the markdown linter
	@echo
	# Running markdownlint against all markdown files in this project...
	@find . -path ./meetups -prune -o -name "*.md" -exec docker run --rm -v `pwd`/{}:/workspace/{} ${MARKDOWN_LINTER} /workspace/{} \;
	@echo ## Successfully linted Markdown.
