const express = require('express');
const app = express();
app.use(express.json());

app.get('/orgs/:owner/teams/:team_name', (req, res) => {
  console.log(`Mock intercepted: GET /orgs/${req.params.owner}/teams/${req.params.team_name}`);
  console.log('Request headers:', JSON.stringify(req.headers));

  // Validate Authorization header
  if (!req.headers.authorization || !req.headers.authorization.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Unauthorized: Missing or invalid Bearer token' });
  }

  // Simulate different responses based on team_name or owner
  if (req.params.team_name === 'test-team' && req.params.owner === 'test-owner') {
    res.status(200).json({ name: 'test-team', slug: 'test-team' });
  } else {
    res.status(404).json({ message: 'Not Found' });
  }
});

app.listen(3000, () => {
  console.log('Mock server listening on http://127.0.0.1:3000...');
});
