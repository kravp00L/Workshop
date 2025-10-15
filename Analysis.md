# Email Investigation

## Overview of analysis objectives
- Adapting the Microsoft playbook to meet our requirements, we'll start with the analysis of a single message. 
- Using the physical analogy of a letter, an email message has different elements.
- There are two key elements of an email message that require investigation.
    - Email Headers
    - Email Content

### Manual email analysis
- Headers
    - Email headers are added to messages by the servers that handle the message as it travels from sender to recipient.
    - Email headers can be spoofed or modified by the sender, but the headers added by your receiving mail server can be trusted.
    - Email headers contain information about the handling and analysis of the message that is not displayed when you view the message.
    - Headers may vary based on the email system used, but these key headers should be present
        - [Received-SPF](https://dmarcian.com/what-is-spf/)
            - Process to identify if a sending host is permitted to send mail for a specific domain
        - Authentication-Results
            - DMARC, DKIM, and SPF information
        - Return-Path
        - [Microsoft specific headers](https://learn.microsoft.com/en-us/exchange/antispam-and-antimalware/antispam-protection/antispam-stamps)
            - X-MS-Exchange-Organization-SCL
            - X-MS-Exchange-Organization-PCL
            - X-MS-Exchange-AtpMessageProperties: SA|SL
        - Google specific headers
    - Viewing message headers        
        - Gmail
            - Open message
            - Click More (three vertical dots on right side if message)
            - Click Show Original
        - Outlook app
            - Open message [not in the preview pane]
            - File > Properties > Internet Headers
        - Outlook web
            - Open message
            - Click More actions (the three horizontal dots on the right side of the message)
            - Click View > View message details
- Content
    - The body of the message has important information to support the analysis.
    - These can be captured by viewing the message or the message source for HTML emails
        - Sender & recipient information
            - From address
            - To address
            - Subject
        - Text of message
        - Images
            - Extract text from images
        - Links
        - Attachments

### Adding initial automation steps
- Moving from the fully manual process, tools can be used to help with the analysis
- Extract and parse the key headers from the message
    - Website option: [Microsoft Message Header Analyzer](https://mha.azurewebsites.net/)
    - Offline option: create a script to parse a stored email message that includes the headers
- Analyze extracted content using third-party tools
    - Link analysis
        - [urlscan.io](https://urlscan.io/search/#*)
        - [urlquery.net](https://urlquery.net/search)
        - [virustotal.com](https://www.virustotal.com/gui/home/search)

### Extending the automation
- Read file that has the headers and email content
- Extract important artifacts
- Perform online lookups to enrich and analyze extracted artifacts
- Output summary of information and findings
- Run script against multiple files


### AI vibes
- Generative AI provides the opportunity to get the analysis done in a single operation
- Obtain API key for Claude Code
- Submit mail sample and prompt to Claude Code via API


