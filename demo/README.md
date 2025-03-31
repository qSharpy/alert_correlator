# Alert Correlator Demo Presentation

This is a web-based demo presentation for the Alert Correlator application. It provides an overview of the application, its capabilities, and how it works.

## How to Use

### Option 1: Run with Node.js (Recommended)

1. Make sure you have Node.js installed
2. Run the start script:
   ```bash
   ./start-demo.sh
   ```
3. Open http://localhost:3005 in your browser

### Option 2: Run with Docker

1. Make sure you have Docker installed
2. Run the following command:
   ```bash
   docker-compose up
   ```
3. Open http://localhost:3005 in your browser

### Option 3: Open Directly in Browser

1. Open the `index.html` file directly in a web browser
2. Note: Some browsers may restrict local file access, which could affect image loading

### Navigation

Navigate through the slides using:
- The "Previous" and "Next" buttons
- Left and right arrow keys
- Spacebar (to advance)

Click on container links to open the respective services in a new tab.

## Presentation Content

The presentation includes:

1. **Introduction**: Overview of the Alert Correlator application
2. **What the App Does**: Explanation of the application's purpose and functionality
3. **Application Overview**: Detailed flow diagram and component explanation
4. **Capabilities**: Key features and capabilities of the system
5. **Main Script Overview**: Simplified explanation of the alert correlator code
6. **Container Demo**: Links to access the different containers
7. **Live Demo**: Instructions for running a live demo
8. **Appendix**: Additional information and resources

## Requirements

- Modern web browser (Chrome, Firefox, Safari, Edge)
- Running Alert Correlator application with all containers started
- Network access to the container ports (localhost)

## Note

Make sure the Alert Correlator application is running before clicking on the container links, as they point to the respective services on localhost.