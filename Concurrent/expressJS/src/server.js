const express = require('express');
const { Worker, isMainThread, parentPort } = require('worker_threads');
const fs = require('fs');
const path = require('path');

const app = express();
const port = 55003;

app.get('/read', (req, res) => {
    const filesToRead = "textFile.txt";

    const worker = new Worker(__filename);

    worker.on('message', (result) => {
        res.json({ success: true, message: result });  // Send results as JSON response
    });

    worker.on('error', (error) => {
        res.status(500).json({ success: false, message: `Worker error: ${error.message}` });
    });

    worker.on('exit', (exitCode) => {
        if (exitCode !== 0) {
            res.status(500).json({ success: false, message: `Worker stopped with exit code ${exitCode}` });
        }
    });

    worker.postMessage(filesToRead);
});

if (isMainThread) {
    app.listen(port, () => {
        console.log(`Server running on http://localhost:${port}`);
    });
} else {
    parentPort.on('message', (file) => {
        const results = [];

        (async () => {
            try {
                const filePath = file;
                const fileContent = fs.readFileSync(path.resolve(__dirname, filePath), 'utf-8');
                results.push(`${fileContent}`);
            } catch (err) {
                results.push(`Error reading file ${files[i]}: ${err.message}`);
            }

            await new Promise(resolve => setTimeout(resolve, 2000));


            parentPort.postMessage(results);
        })();
    });
}
