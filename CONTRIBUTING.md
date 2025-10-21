# Contributing to Crash-Proofing Your OpenTelemetry Collector

Thank you for your interest in contributing to this project!
We welcome contributions from the community to help improve this
demonstration and educational resource.

## How to Contribute

### Reporting Issues

If you find a bug, have a question, or want to suggest an improvement:

1. Check the [existing issues](../../issues) to see if it's already been reported
2. If not, open a new issue with a clear description
3. Include relevant details such as:
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - Your environment (OS, Docker version, etc.)

### Submitting Changes

We welcome pull requests for:

- Bug fixes
- Documentation improvements
- Configuration enhancements
- Additional test scenarios
- Code optimizations

#### Process

1. Fork the repository
2. Create a new branch for your changes (`git checkout -b feature/your-feature-name`)
3. Make your changes
4. Test your changes thoroughly:

   ```bash
   ./run_test.sh batch_processor
   ./run_test.sh otlp_batcher
   ./run_test.sh cleanup
   ```

5. Commit your changes with clear, descriptive commit messages
6. Push to your fork
7. Open a pull request with a description of your changes

### Code Guidelines

- Keep configurations clear and well-documented
- Follow existing code style and formatting
- Add comments where necessary to explain complex logic
- Update documentation (README.md) if your changes affect usage

### Documentation

If your contribution changes how the demo works:

- Update the [README.md](README.md) with relevant information
- Add inline comments to configuration files if needed
- Update examples if they no longer match the current behavior

## Questions?

If you have questions about contributing, feel free to:

- Open an issue for discussion
- Reach out to the maintainers

## Code of Conduct

We follow the [CNCF code of conduct][1] and we are committed
to providing a welcoming and inclusive environment.
Please be respectful and constructive in all interactions.

---

Thank you for helping make this project better!

[1]: https://github.com/cncf/foundation/blob/main/code-of-conduct.md#our-standards