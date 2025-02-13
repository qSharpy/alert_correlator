import express from 'express';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import fetch from 'node-fetch';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();
const port = 3003;

// Current LLM provider state
let currentProvider = 'openai';
let currentModel = 'gpt-3.5-turbo';

const GPT_MODELS = [
    'gpt-3.5-turbo',
    'gpt-4',
    'gpt-4-turbo'
];

app.use(express.json());
app.use(express.static(__dirname));

// API endpoint to get available GPT models
app.get('/api/models/gpt', (req, res) => {
    res.json({ models: GPT_MODELS });
});

// API endpoint to list available Ollama models
app.get('/api/models/ollama', async (req, res) => {
    try {
        const response = await fetch(`${process.env.OLLAMA_BASE_URL}/api/tags`);
        if (!response.ok) throw new Error('Failed to fetch Ollama models');
        const data = await response.json();
        res.json({ models: data.models });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// API endpoint to check if Ollama model is installed
app.get('/api/models/ollama/:model/status', async (req, res) => {
    try {
        const response = await fetch(`${process.env.OLLAMA_BASE_URL}/api/tags`);
        if (!response.ok) throw new Error('Failed to fetch Ollama models');
        const data = await response.json();
        const isInstalled = data.models.some(m => m.name === req.params.model);
        res.json({ installed: isInstalled });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// API endpoint to install Ollama model
app.post('/api/models/ollama/:model/install', async (req, res) => {
    try {
        const response = await fetch(`${process.env.OLLAMA_BASE_URL}/api/pull`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ name: req.params.model })
        });
        if (!response.ok) throw new Error('Failed to install model');
        res.json({ status: 'success' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// API endpoint to update LLM configuration
app.post('/api/config/llm', (req, res) => {
    const { provider, model } = req.body;
    
    if (!provider || !['openai', 'ollama'].includes(provider)) {
        return res.status(400).json({ error: 'Invalid provider' });
    }

    if (!model) {
        return res.status(400).json({ error: 'Model is required' });
    }

    currentProvider = provider;
    currentModel = model;
    console.log(`Switched to ${provider} using model: ${model}`);
    res.json({ status: 'success', provider, model });
});

// API endpoint to get current configuration
app.get('/api/config/llm', (req, res) => {
    res.json({ provider: currentProvider, model: currentModel });
});

// Serve index.html for all other routes
app.get('*', (req, res) => {
    res.sendFile(join(__dirname, 'index.html'));
});

app.listen(port, '0.0.0.0', () => {
    console.log(`LLM Service running at http://localhost:${port}`);
});