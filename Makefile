.PHONY: mockgen-v1 mockgen-v2 test test-v1 test-v2 lint integration-test
mockgen-v1:
	mockgen -source=pkg/openfeature/provider.go -destination=pkg/openfeature/provider_mock_test.go -package=openfeature
	mockgen -source=pkg/openfeature/hooks.go -destination=pkg/openfeature/hooks_mock_test.go -package=openfeature
	mockgen -source=pkg/openfeature/mutex.go -destination=pkg/openfeature/mutex_mock_test.go -package=openfeature
mockgen-v2:
	mockgen -source=pkg/openfeature/v2/provider.go -destination=pkg/openfeature/v2/provider_mock_test.go -package=openfeature
	mockgen -source=pkg/openfeature/v2/hooks.go -destination=pkg/openfeature/v2/hooks_mock_test.go -package=openfeature
	mockgen -source=pkg/openfeature/v2/mutex.go -destination=pkg/openfeature/v2/mutex_mock_test.go -package=openfeature

test:
	make test-v1
	make test-v2
test-v1:
	go test --short -cover ./...
test-v2:
	cd ./pkg/openfeature/v2; go test --short -cover ./...

integration-test: # dependent on: docker run -p 8013:8013 -v $PWD/test-harness/testing-flags.json:/testing-flags.json ghcr.io/open-feature/flagd-testbed:latest
	go test -cover ./...
	cd test-harness; git restore testing-flags.json; cd .. # reset testing-flags.json

lint:
	go install -v github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	${GOPATH}/bin/golangci-lint run --deadline=3m --timeout=3m ./... # Run linters
	cd ./pkg/openfeature/v2; ${GOPATH}/bin/golangci-lint run --deadline=3m --timeout=3m ./... # Run linters
