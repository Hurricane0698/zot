import contextlib
import importlib.machinery
import importlib.util
import io
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock


ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = ROOT / "scripts"


def load_script(name: str, path: Path):
    loader = importlib.machinery.SourceFileLoader(name, str(path))
    spec = importlib.util.spec_from_loader(name, loader)
    module = importlib.util.module_from_spec(spec)
    loader.exec_module(module)
    return module


class TTYStringIO(io.StringIO):
    def isatty(self) -> bool:
        return True


class FeedbackWorkflowTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.kb_lint = load_script("test_kb_lint", SCRIPTS / "kb-lint")
        cls.kb_feedback = load_script("test_kb_feedback", SCRIPTS / "kb-feedback")

    def test_normalize_target_only_strips_markdown_suffix(self):
        self.assertEqual(
            self.kb_lint.normalize_target("kb/wiki/methods/Local AI workflow.md"),
            "Local AI workflow",
        )
        self.assertEqual(
            self.kb_lint.normalize_target("[[release/v1.2.md]]"),
            "v1.2",
        )
        self.assertEqual(
            self.kb_lint.normalize_target("[[release/v1.2]]"),
            "v1.2",
        )

    def test_kb_feedback_emits_yaml_safe_frontmatter(self):
        title = 'Bob\'s "API" issue'
        target = 'kb/wiki/methods/Bob\'s "API" issue.md'
        author = 'Ann "Ops" O\'Brien'

        with tempfile.TemporaryDirectory() as tmpdir:
            repo = Path(tmpdir)
            output = repo / "kb" / "human" / "feedback" / "open" / "quoted.md"
            output.parent.mkdir(parents=True, exist_ok=True)

            create_stdout = io.StringIO()
            with (
                mock.patch.object(self.kb_feedback, "REPO", repo),
                mock.patch.object(self.kb_feedback, "FEEDBACK_ROOT", output.parent),
                mock.patch.object(sys, "argv", [
                    "kb-feedback",
                    "--title",
                    title,
                    "--target",
                    target,
                    "--author",
                    author,
                    "--path",
                    str(output.relative_to(repo)),
                ]),
                mock.patch.object(sys, "stdin", TTYStringIO("")),
                contextlib.redirect_stdout(create_stdout),
            ):
                self.assertEqual(self.kb_feedback.main(), 0)

            text = output.read_text(encoding="utf-8")
            self.assertIn("title: 'Bob''s \"API\" issue'", text)
            self.assertIn("target: 'kb/wiki/methods/Bob''s \"API\" issue.md'", text)
            self.assertIn("author: 'Ann \"Ops\" O''Brien'", text)

            frontmatter = self.kb_lint.parse_frontmatter(text)
            self.assertIsNotNone(frontmatter)
            self.assertEqual(frontmatter["title"], title)
            self.assertEqual(frontmatter["target"], target)
            self.assertEqual(frontmatter["author"], author)

    def test_kb_lint_accepts_feedback_targets_with_markdown_paths(self):
        note_name = 'Bob\'s "API" issue'
        target = f"kb/wiki/methods/{note_name}.md"
        title = f"{note_name} feedback"

        with tempfile.TemporaryDirectory() as tmpdir:
            repo = Path(tmpdir)
            wiki_note = repo / "kb" / "wiki" / "methods" / f"{note_name}.md"
            wiki_note.parent.mkdir(parents=True, exist_ok=True)
            wiki_note.write_text(
                "\n".join(
                    [
                        "---",
                        f"title: {self.kb_feedback.yaml_scalar(note_name)}",
                        "---",
                        "",
                        "# Note",
                        "",
                        "## Sources",
                        "",
                        "- synthetic test",
                        "",
                    ]
                ),
                encoding="utf-8",
            )

            feedback_path = repo / "kb" / "human" / "feedback" / "open" / "test.md"
            feedback_path.parent.mkdir(parents=True, exist_ok=True)

            create_stdout = io.StringIO()
            with (
                mock.patch.object(self.kb_feedback, "REPO", repo),
                mock.patch.object(self.kb_feedback, "FEEDBACK_ROOT", feedback_path.parent),
                mock.patch.object(sys, "argv", [
                    "kb-feedback",
                    "--title",
                    title,
                    "--target",
                    target,
                    "--author",
                    "tester",
                    "--path",
                    str(feedback_path.relative_to(repo)),
                ]),
                mock.patch.object(sys, "stdin", TTYStringIO("")),
                contextlib.redirect_stdout(create_stdout),
            ):
                self.assertEqual(self.kb_feedback.main(), 0)

            stdout = io.StringIO()
            with (
                mock.patch.object(self.kb_lint, "REPO", repo),
                mock.patch.object(self.kb_lint, "KB", repo / "kb"),
                mock.patch.object(self.kb_lint, "WIKI", repo / "kb" / "wiki"),
                mock.patch.object(self.kb_lint, "META", repo / "kb" / "meta"),
                mock.patch.object(self.kb_lint, "FEEDBACK", repo / "kb" / "human" / "feedback"),
                contextlib.redirect_stdout(stdout),
            ):
                self.assertEqual(self.kb_lint.main(), 0)

            output = stdout.getvalue()
            self.assertIn("Feedback target issues: 0", output)
            self.assertNotIn("FEEDBACK TARGET:", output)


if __name__ == "__main__":
    unittest.main()
