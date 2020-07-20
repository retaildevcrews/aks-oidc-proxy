---
name: Release Checklist
about: DescVerify code is ready to releaseribe this issue template's purpose here.
title: ''
labels: Release
assignees: ''

---

This checklist is for verifying the release is ready to publish and published correctly.

## Release
- Title / Repo
- vx.x.x.x

### Validation
- [ ] All packages up to date (or task created)
- [ ] Remove unused packages
- [ ] Code Version updated
- [ ] Code Review completed
- [ ] All existing automated tests (unit and e2e) pass successfully, new tests added as needed
- [ ] Code changes checked into master
- [ ] Sync github actions from master template
- [ ] Existing documentation is updated (readme, .md's)
- [ ] New documentation needed to support the change is created
- [ ] CI completes successfully
- [ ] CD completes successfully
- [ ] Smoke test deployed for 48 hours

### Release
- [ ] Reviewed & updated readme for Developer Experience
- [ ] Resolve to-do from code
- [ ] Verify all new libraries and dependencies are customer approved
- [ ] Tag repo with version tag
- [ ] Ensure CI-CD runs correctly
- [ ] Ran cred scan
- [ ] Removed workflow for issue triage and PR submission
- [ ] Validate e2e testing
- [ ] Close Release Task
