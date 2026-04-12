import json
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
INIT_PROJECT = ROOT / "scripts" / "init-project"
START_SESSION = ROOT / "scripts" / "start-session"


class StartSessionTests(unittest.TestCase):
    def test_json_output_includes_structured_project_standards(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            tmp = Path(tmpdir)
            project = tmp / "my-app"
            vault = tmp / "vault"
            project.mkdir()
            (project / "README.md").write_text("# My App\n", encoding="utf-8")

            subprocess.run(["git", "init", "-q"], cwd=project, check=True)

            init_result = subprocess.run(
                [str(INIT_PROJECT), str(project), "--vault", str(vault)],
                check=False,
                capture_output=True,
                text=True,
            )
            self.assertEqual(init_result.returncode, 0, msg=init_result.stderr)

            standards_note = vault / "kb" / "wiki" / "projects" / "my-app.standards.md"
            standards_text = standards_note.read_text(encoding="utf-8")
            standards_text = standards_text.replace("tech_stack: []", "tech_stack: ['bash', 'python']")
            standards_text = standards_text.replace(
                "architectural_style: ''",
                "architectural_style: 'script-first'",
            )
            standards_text = standards_text.replace(
                "testing_policy: []",
                "testing_policy: ['unittest']",
            )
            standards_note.write_text(standards_text, encoding="utf-8")

            result = subprocess.run(
                [str(START_SESSION), "--json", "--vault", str(vault)],
                cwd=project,
                check=False,
                capture_output=True,
                text=True,
            )
            self.assertEqual(result.returncode, 0, msg=result.stderr)

            payload = json.loads(result.stdout)
            self.assertTrue(payload["project_note"]["exists"])
            self.assertTrue(payload["project_standards"]["exists"])
            self.assertEqual(
                payload["project_standards"]["relative_path"],
                "kb/wiki/projects/my-app.standards.md",
            )
            self.assertEqual(
                payload["structured_context"]["project"]["standards_note"],
                "projects/my-app.standards",
            )
            self.assertEqual(
                payload["structured_context"]["standards"]["tech_stack"],
                ["bash", "python"],
            )
            self.assertEqual(
                payload["structured_context"]["standards"]["architectural_style"],
                "script-first",
            )
            self.assertIn("AGENTS.md", payload["structured_context"]["evidence_paths"])
            self.assertIn("README.md", payload["structured_context"]["evidence_paths"])
            self.assertIn(
                "kb/wiki/projects/my-app.standards.md",
                payload["structured_context"]["evidence_paths"],
            )


if __name__ == "__main__":
    unittest.main()
