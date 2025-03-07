import http from 'k6/http';
import { check, sleep } from 'k6';
import { randomIntBetween } from 'https://jslib.k6.io/k6-utils/1.4.0/index.js';
import { Trend } from 'k6/metrics';

// Define server configurations
const servers = [
    { name: 'Express', port: 55001 },
    { name: 'Dotnet', port: 55011 },
    { name: 'Laravel', port: 55021 },
    { name: 'Go', port: 55031 },
    { name: 'Phoenix', port: 55041 },
];

// Define load test ramp-up
const vuCounts = [1, 20, 100, 500, 2000, 10000, 20000];

// Request duration metric
const requestDuration = new Trend('request_duration', true);

// Command-line options
const selectedServer = __ENV.SERVER || 'ALL';
const cooldownTime = __ENV.COOLDOWN ? parseInt(__ENV.COOLDOWN, 10) : 5;
const autoContinue = __ENV.AUTO_CONTINUE === 'true';
const vucount = __ENV.VU && parseInt(__ENV.VU) && (parseInt(__ENV.VU) >= 0 && parseInt(__ENV.VU) < vuCounts.length) && Number.isInteger(vuCounts[parseInt(__ENV.VU)]) 
           ? vuCounts[parseInt(__ENV.VU)] : vuCounts[0];
// Function to generate random post IDs
function generatePostIds() {
    return Array.from({ length: 5 }, () => randomIntBetween(100, 9000)); // Random post IDs between 100-9000
}

export default function () {
    const serversToTest = selectedServer.toUpperCase() === 'ALL'
        ? servers
        : servers.filter((server) => server.name.toLowerCase() === selectedServer.toLowerCase());

    if (serversToTest.length === 0) {
        console.error(`Error: No matching server found for '${selectedServer}'.`);
        return;
    }

    for (let i = 0; i < serversToTest.length; i++) {
        const { name, port } = serversToTest[i];
        const url = `http://localhost:${port}/comments/delete-bulk`;

 

        let moveToNextServer = false;

        for (let vu of vuCounts) {
            if (!autoContinue && vucount) {
                vu = vucount;
            }
            if (moveToNextServer) break;

 

            for (let j = 0; j < vu; j++) {
                const payload = JSON.stringify({ postIDs: generatePostIds() });
                const params = { headers: { 'Content-Type': 'application/json' } };
                const startTime = Date.now();
                const response = http.post(url, payload, params, { timeout: "9999999s" });
                const endTime = Date.now();
                requestDuration.add(endTime - startTime);

                check(response, { 'status is 2xx': (r) => r.status >= 200 && r.status < 300 });

                if (response.status >= 400) {
                    console.warn(`⚠️ Request failed for ${name} on port ${port} at ${vu} users: Status ${response.status}`);
                    moveToNextServer = true;
                    break;
                }
            }

            if (moveToNextServer) {
                console.log(`Stopping benchmark for ${name} on port ${port}: Failed at ${vu} users. Moving to next server.\n`);
                break;
            }

             if (!autoContinue) {
                 return;
            }

 
        }

 
        sleep(1);
    }
}
