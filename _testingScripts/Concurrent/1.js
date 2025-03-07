import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend } from 'k6/metrics';

// Define ports and their corresponding server names
const servers = [
    { name: 'Express', port: 55003 },
    { name: 'Dotnet', port: 55013 },
    { name: 'Laravel', port: 55023 },
    { name: 'Go', port: 55033 },
    { name: 'Phoenix', port: 55043 },
];

// Ramp-up configuration
const vuCounts = [1, 20, 100, 500, 2000, 10000, 20000];
const endpoint = '/read'; // Adjust this endpoint as needed

// Metrics for tracking request durations
const requestDuration = new Trend('request_duration', true);

// Command-line argument handling
const selectedServer = __ENV.SERVER || 'ALL'; // Example: SERVER=Express or SERVER=ALL
const cooldownTime = __ENV.COOLDOWN ? parseInt(__ENV.COOLDOWN, 10) : 5; // Cooldown time in seconds
const autoContinue = __ENV.AUTO_CONTINUE === 'true'; // Automatically continue to the next level if true
const vucount = __ENV.VU && parseInt(__ENV.VU) && (parseInt(__ENV.VU) >= 0 && parseInt(__ENV.VU) < vuCounts.length) && Number.isInteger(vuCounts[parseInt(__ENV.VU)])
    ? vuCounts[parseInt(__ENV.VU)] : vuCounts[0];
export default function () {
    const serversToTest =
        selectedServer.toUpperCase() === 'ALL'
            ? servers
            : servers.filter((server) => server.name.toLowerCase() === selectedServer.toLowerCase());

    if (serversToTest.length === 0) {
        console.error(`Error: No matching server found for '${selectedServer}'.`);
        return;
    }

    for (let i = 0; i < serversToTest.length; i++) {
        const { name, port } = serversToTest[i];
        const url = `http://localhost:${port}${endpoint}`;

        let moveToNextServer = false; // Flag to move to the next server

        let vu = vucount
        if (!autoContinue && vucount) {
            vu = vucount;
        };

        let allSuccess = true; // Track if all requests succeed at this VU count

        for (let j = 0; j < vu; j++) {
            const startTime = Date.now(); // Track start time
            const response = http.get(url, { timeout: "9999999s" });
            const endTime = Date.now(); // Track end time

            const duration = endTime - startTime; // Calculate duration
            requestDuration.add(duration); // Log request duration

            const success = check(response, {
                'status is 2xx': (r) => r.status >= 200 && r.status < 300,
            });

            if (!success) {
                console.warn(
                    `⚠️ Request failed for ${name} on port ${port} at ${vu} users: Status ${response.status} \n ${response}`
                );

                // Stop ramp-up for this server and move to the next
                moveToNextServer = true;
                break;
            }
        }

        if (moveToNextServer) {
            console.log(
                `Stopping benchmark for ${name} on port ${port}: Failed at ${vu} users. Moving to next server.\n`
            );
            break;
        }

        if (!autoContinue) {
            return; // Exit the script until the next manual run
        }
        sleep(1); // Pause between servers
    }
}
