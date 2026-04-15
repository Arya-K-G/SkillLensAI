from __future__ import annotations

from typing import Dict, List


def _role(
    role_name: str,
    company: str,
    location: str,
    level: str,
    tags: List[str],
    summary: str,
    industry: str,
) -> Dict[str, object]:
    return {
        "id": role_name.lower().replace(" ", "-").replace("/", "-"),
        "role_name": role_name,
        "company": company,
        "location": location,
        "level": level,
        "tags": tags,
        "summary": summary,
        "industry": industry,
    }


ROLE_LIBRARY: List[Dict[str, object]] = [
    _role("Flutter Developer", "Google-style Product Team", "Bengaluru, India", "Mid Level", ["Flutter", "Dart", "Firebase", "REST APIs"], "Build polished mobile experiences with performance, testing, and reusable UI systems.", "Technology"),
    _role("NLP Engineer", "OpenAI-style Applied AI Lab", "Remote", "Mid Level", ["Python", "NLP", "Machine Learning", "TensorFlow"], "Design text intelligence systems for search, ranking, semantic matching, and extraction.", "AI"),
    _role("Machine Learning Engineer", "Amazon-style Platform Team", "Hyderabad, India", "Mid Level", ["Python", "Machine Learning", "AWS", "Docker"], "Productionize models, manage training pipelines, and support reliable ML-backed features.", "AI"),
    _role("Frontend Engineer", "Netflix-style Consumer UI Team", "Remote", "Mid Level", ["JavaScript", "React", "HTML", "CSS"], "Build accessible, responsive, and high-performance web interfaces.", "Technology"),
    _role("Backend Engineer", "Stripe-style Payments Team", "Bengaluru, India", "Mid Level", ["Java", "SQL", "REST APIs", "AWS"], "Design reliable APIs and services for high-volume transactional systems.", "Technology"),
    _role("Data Analyst", "Meta-style Growth Analytics Team", "Remote", "Associate", ["SQL", "Python", "Data Analysis"], "Translate business questions into measurable insights using dashboards and reporting.", "Analytics"),
    _role("Android Developer", "Samsung-style Mobile Team", "Noida, India", "Mid Level", ["Android", "Java", "REST APIs", "Git"], "Create performant native mobile apps with lifecycle handling and release quality.", "Technology"),
    _role("Product Designer", "Airbnb-style Experience Team", "Remote", "Mid Level", ["UI", "UX", "Research", "Design Systems"], "Shape user journeys, design flows, and collaborate deeply with product teams.", "Design"),
    _role("Registered Nurse", "Apollo Hospitals", "Mumbai, India", "Experienced", ["Patient Care", "Clinical Documentation", "Safety", "Care Coordination"], "Deliver patient-centered care with empathy, accurate charting, and safe clinical practice.", "Healthcare"),
    _role("Medical Laboratory Technician", "Quest Diagnostics", "Chennai, India", "Mid Level", ["Diagnostics", "Lab Safety", "Sample Processing", "Quality Control"], "Process specimens, run instruments, and maintain diagnostic quality standards.", "Healthcare"),
    _role("Teacher", "International School", "Delhi, India", "Mid Level", ["Teaching", "Curriculum", "Classroom Management", "Assessment"], "Plan lessons, manage classrooms, assess learning, and support student growth.", "Education"),
    _role("Professor", "University Research Department", "Bengaluru, India", "Senior", ["Research", "Mentoring", "Curriculum", "Publications"], "Deliver lectures, mentor students, lead research, and develop academic programs.", "Education"),
    _role("Accountant", "Deloitte", "Hyderabad, India", "Mid Level", ["Accounting", "Financial Reporting", "Tax", "Compliance"], "Manage books, prepare reports, and support tax and compliance workflows.", "Finance"),
    _role("Financial Analyst", "Goldman Sachs", "Mumbai, India", "Mid Level", ["Excel", "Forecasting", "Valuation", "Reporting"], "Build forecasts, analyze performance, and present financial insights.", "Finance"),
    _role("Sales Manager", "Salesforce Partner", "Pune, India", "Mid Level", ["Sales", "Lead Generation", "CRM", "Negotiation"], "Lead pipeline growth, coach reps, manage CRM, and close strategic deals.", "Sales"),
    _role("Marketing Specialist", "Nike India", "Remote", "Mid Level", ["Brand", "Campaigns", "Content", "Analytics"], "Plan campaigns, create content, and analyze performance across channels.", "Marketing"),
    _role("Human Resources Generalist", "Accenture", "Gurugram, India", "Mid Level", ["Recruitment", "Employee Relations", "Onboarding", "Policy"], "Support recruitment, onboarding, policy communication, and employee relations.", "Human Resources"),
    _role("Operations Manager", "Amazon Logistics", "Delhi NCR, India", "Senior", ["Operations", "Process Improvement", "Supply Chain", "Reporting"], "Improve workflows, monitor metrics, and coordinate teams across operations.", "Operations"),
    _role("Supply Chain Analyst", "Flipkart", "Bengaluru, India", "Mid Level", ["Inventory", "Forecasting", "Logistics", "Excel"], "Analyze inventory, forecast demand, and identify logistics improvements.", "Operations"),
    _role("Legal Assistant", "Khaitan & Co", "Kolkata, India", "Entry to Mid", ["Documentation", "Research", "Compliance", "Drafting"], "Support drafting, documentation, legal research, and case file organization.", "Legal"),
    _role("Architect", "SOM Design Studio", "Mumbai, India", "Senior", ["Design", "CAD", "Planning", "Construction"], "Create design concepts, drawings, and coordinate execution with engineers.", "Construction"),
    _role("Civil Engineer", "L&T Construction", "Chennai, India", "Mid Level", ["Construction", "Site Management", "Planning", "Safety"], "Support site planning, coordination, quality checks, and safety compliance.", "Construction"),
    _role("Mechanical Engineer", "Siemens", "Pune, India", "Mid Level", ["Mechanical Design", "Manufacturing", "CAD", "Quality"], "Support design, troubleshooting, manufacturing coordination, and quality improvement.", "Engineering"),
    _role("Pilot", "IndiGo", "Pan India", "Senior", ["Aviation", "Safety", "Navigation", "Operations"], "Manage flight operations, navigation, communication, and compliance.", "Aviation"),
    _role("Chef", "Taj Hotels", "Goa, India", "Mid Level", ["Culinary", "Food Safety", "Menu Design", "Kitchen Operations"], "Prepare quality dishes, manage kitchen operations, and maintain food safety.", "Hospitality"),
    _role("Hotel Manager", "Marriott International", "Jaipur, India", "Senior", ["Hospitality", "Guest Experience", "Operations", "Team Leadership"], "Oversee guest experience, operations, staff coordination, and service quality.", "Hospitality"),
    _role("UX Researcher", "Spotify", "Remote", "Mid Level", ["Research", "Interviews", "Usability", "Insights"], "Design studies, conduct interviews, and synthesize actionable product insights.", "Design"),
    _role("Content Writer", "HubSpot", "Remote", "Mid Level", ["Writing", "SEO", "Editing", "Content Strategy"], "Research topics, create clear content, and optimize for SEO and brand tone.", "Marketing"),
    _role("Customer Support Specialist", "Zendesk Customer Ops", "Remote", "Entry to Mid", ["Support", "Communication", "Problem Solving", "CRM"], "Resolve issues, document interactions, and support customer success.", "Customer Success"),
    _role("DevOps Engineer", "Atlassian Cloud Team", "Remote", "Mid Level", ["Docker", "Kubernetes", "CI/CD", "AWS"], "Automate deployments, improve reliability, and manage cloud infrastructure.", "Technology"),
    _role("Cloud Engineer", "Microsoft Azure Team", "Remote", "Mid Level", ["Cloud", "Networking", "Security", "Automation"], "Design and support cloud systems with reliability and security in mind.", "Cloud"),
    _role("Data Engineer", "LinkedIn Data Platform", "Remote", "Mid Level", ["Python", "SQL", "ETL", "Warehousing"], "Build data pipelines, warehouse models, and analytics-ready datasets.", "Analytics"),
    _role("QA Engineer", "Adobe Experience Team", "Remote", "Mid Level", ["Testing", "Automation", "Bug Tracking", "CI/CD"], "Validate products, automate tests, and protect release quality.", "Quality Assurance"),
    _role("Business Analyst", "McKinsey Digital", "Remote", "Mid Level", ["Research", "Excel", "Reporting", "Stakeholder Management"], "Translate business problems into structured analysis and recommendations.", "Consulting"),
    _role("Project Manager", "PMO Consulting Group", "Remote", "Senior", ["Planning", "Delivery", "Stakeholders", "Risk"], "Lead delivery, coordinate stakeholders, and manage scope and risk.", "Operations"),
    _role("Social Media Manager", "Coca-Cola Brand Team", "Remote", "Mid Level", ["Content", "Campaigns", "Brand", "Analytics"], "Manage social calendars, content quality, and engagement performance.", "Marketing"),
    _role("Recruiter", "Talent Acquisition Team", "Remote", "Mid Level", ["Hiring", "Interviewing", "Sourcing", "ATS"], "Source candidates, run interviews, and coordinate hiring pipelines.", "Human Resources"),
    _role("Cybersecurity Analyst", "Security Operations Center", "Remote", "Mid Level", ["Security", "Threat Detection", "Incident Response", "Monitoring"], "Monitor threats, investigate incidents, and strengthen defenses.", "Security"),
    _role("Pharmacist", "Apollo Pharmacy", "Mumbai, India", "Mid Level", ["Dispensing", "Medication Safety", "Counseling", "Compliance"], "Dispense medications, counsel patients, and ensure medication safety.", "Healthcare"),
    _role("Dentist", "Clove Dental", "Bengaluru, India", "Mid Level", ["Diagnosis", "Treatment", "Patient Care", "Sterilization"], "Deliver oral care, diagnosis, treatment, and patient guidance.", "Healthcare"),
    _role("Counselor", "Mind Matters Clinic", "Remote", "Mid Level", ["Counseling", "Empathy", "Assessment", "Documentation"], "Support clients with assessment, counseling, and care planning.", "Healthcare"),
    _role("Event Manager", "Eventbrite India", "Remote", "Mid Level", ["Planning", "Vendor Management", "Execution", "Budgeting"], "Plan events, manage vendors, and coordinate end-to-end execution.", "Events"),
    _role("Electrician", "Infrastructure Services", "Delhi, India", "Mid Level", ["Electrical", "Safety", "Maintenance", "Troubleshooting"], "Install, maintain, and troubleshoot electrical systems safely.", "Trades"),
    _role("Plumber", "Facilities Maintenance", "Mumbai, India", "Mid Level", ["Plumbing", "Safety", "Repair", "Maintenance"], "Install and repair plumbing systems for residential and commercial sites.", "Trades"),
    _role("Mechanic", "Auto Service Center", "Pune, India", "Mid Level", ["Automotive", "Repair", "Diagnostics", "Maintenance"], "Diagnose and repair vehicles while maintaining safety and service quality.", "Trades"),
    _role("Research Scientist", "DeepMind-style Research Lab", "Remote", "Senior", ["Research", "Experiments", "Papers", "Python"], "Advance scientific research through experiments, publications, and prototypes.", "Research"),
    _role("Government Officer", "Public Service Department", "Delhi, India", "Senior", ["Policy", "Administration", "Documentation", "Public Service"], "Support administration, policy execution, and citizen-facing operations.", "Government"),
    _role("Construction Manager", "Skanska Projects", "Hyderabad, India", "Senior", ["Construction", "Planning", "Site Safety", "Coordination"], "Coordinate site work, vendors, safety, and project delivery.", "Construction"),
    _role("Retail Store Manager", "Reliance Retail", "Kochi, India", "Mid Level", ["Retail", "Sales", "Inventory", "Team Leadership"], "Manage store performance, customer service, staffing, and inventory.", "Retail"),
    _role("Procurement Specialist", "Unilever Supply Team", "Remote", "Mid Level", ["Procurement", "Negotiation", "Vendor Management", "Contracts"], "Source vendors, negotiate terms, and manage procurement operations.", "Operations"),
    _role("Warehouse Supervisor", "DHL Logistics", "Delhi NCR, India", "Mid Level", ["Warehouse", "Logistics", "Inventory", "Safety"], "Oversee warehouse operations, inventory control, and safety compliance.", "Operations"),
    _role("Insurance Advisor", "HDFC Life", "Remote", "Mid Level", ["Sales", "Insurance", "Customer Communication", "Compliance"], "Explain policies, support client needs, and manage compliant sales workflows.", "Finance"),
    _role("Real Estate Agent", "CBRE", "Mumbai, India", "Mid Level", ["Sales", "Property", "Negotiation", "Client Relations"], "Guide buyers and sellers through property evaluation and closing.", "Sales"),
    _role("Veterinarian", "Paws & Claws Animal Hospital", "Bengaluru, India", "Mid Level", ["Animal Care", "Diagnosis", "Treatment", "Surgery"], "Provide medical care, diagnosis, treatment, and preventive guidance for animals.", "Healthcare"),
    _role("Psychologist", "MindCare Clinic", "Remote", "Senior", ["Assessment", "Counseling", "Diagnosis", "Documentation"], "Assess clients, provide therapy, and document treatment plans.", "Healthcare"),
    _role("Nutritionist", "HealthifyMe", "Remote", "Mid Level", ["Diet Planning", "Counseling", "Health", "Research"], "Create nutrition plans, counsel clients, and support wellness goals.", "Healthcare"),
    _role("Librarian", "City Public Library", "Chennai, India", "Mid Level", ["Cataloging", "Research", "Documentation", "Public Service"], "Manage collections, help patrons, and organize resources.", "Education"),
    _role("Journalist", "The Hindu", "Remote", "Mid Level", ["Writing", "Research", "Editing", "Reporting"], "Investigate stories, write articles, and verify facts under deadlines.", "Media"),
    _role("Translator", "LinguaPro Services", "Remote", "Mid Level", ["Translation", "Linguistics", "Editing", "Localization"], "Translate content accurately while preserving tone and meaning.", "Language"),
    _role("Copywriter", "Ogilvy India", "Remote", "Mid Level", ["Writing", "Brand", "Campaigns", "Editing"], "Write persuasive copy for campaigns, ads, and product launches.", "Marketing"),
    _role("Salesforce Administrator", "SaaS Growth Team", "Remote", "Mid Level", ["CRM", "Automation", "Workflows", "Reporting"], "Maintain CRM systems, workflows, and user permissions.", "Technology"),
    _role("ERP Consultant", "SAP Partner Network", "Remote", "Senior", ["ERP", "Implementation", "Support", "Training"], "Configure ERP solutions and support business process adoption.", "Technology"),
    _role("GIS Analyst", "Environmental Mapping Lab", "Remote", "Mid Level", ["GIS", "Mapping", "Spatial Analysis", "Python"], "Analyze spatial data and build mapping outputs for decision-making.", "Analytics"),
    _role("Environmental Scientist", "GreenEarth Initiative", "Remote", "Mid Level", ["Research", "Field Work", "Reporting", "Compliance"], "Study environmental impact, collect data, and report findings.", "Research"),
    _role("Animator", "Pixar-style Studio", "Remote", "Mid Level", ["Animation", "Storytelling", "Design", "Motion"], "Create motion assets and visual storytelling sequences.", "Design"),
    _role("3D Artist", "Game Studio", "Remote", "Mid Level", ["3D Modeling", "Texturing", "Animation", "Design"], "Model assets and create visual content for real-time experiences.", "Design"),
    _role("Game Developer", "Unity Studio", "Remote", "Mid Level", ["Unity", "C#", "Game Design", "Physics"], "Build gameplay systems, mechanics, and interactive experiences.", "Gaming"),
    _role("Mobile Product Manager", "Fintech Super App", "Bengaluru, India", "Senior", ["Product Strategy", "Roadmap", "Analytics", "Stakeholders"], "Own the mobile product roadmap and coordinate cross-functional delivery.", "Product"),
    _role("Product Manager", "SaaS Growth Team", "Remote", "Senior", ["Strategy", "Roadmap", "Analytics", "Stakeholders"], "Lead product discovery, roadmap decisions, and cross-functional delivery.", "Product"),
    _role("Technical Writer", "Developer Tools Startup", "Remote", "Mid Level", ["Writing", "Docs", "API", "Research"], "Create clear documentation for technical products and workflows.", "Technology"),
    _role("Database Administrator", "Enterprise Data Team", "Remote", "Mid Level", ["SQL", "Backup", "Performance", "Security"], "Maintain databases, backups, tuning, and access controls.", "Technology"),
    _role("Biochemist", "Life Sciences Lab", "Hyderabad, India", "Mid Level", ["Research", "Lab Work", "Analysis", "Reporting"], "Run experiments, analyze results, and support research projects.", "Research"),
    _role("Data Scientist", "Spotify AI Team", "Remote", "Mid Level", ["Python", "Statistics", "Machine Learning", "Experimentation"], "Build experiments and models to improve product intelligence.", "AI"),
    _role("AI Product Specialist", "OpenAI-style Applied Products", "Remote", "Mid Level", ["AI", "NLP", "Product", "Evaluation"], "Bridge AI capabilities with product needs and user outcomes.", "AI"),
    _role("Customer Success Manager", "Zoom", "Remote", "Mid Level", ["Customer Success", "Account Management", "Communication", "Retention"], "Help customers adopt the product and drive long-term retention.", "Customer Success"),
    _role("Inside Sales Representative", "HubSpot", "Remote", "Entry to Mid", ["Sales", "CRM", "Outreach", "Discovery"], "Drive pipeline through outreach, discovery, and CRM discipline.", "Sales"),
    _role("Product Owner", "Insurance Tech Team", "Remote", "Senior", ["Agile", "Backlog", "Stakeholders", "Delivery"], "Translate business needs into backlog priorities and delivery outcomes.", "Product"),
    _role("Network Engineer", "Cisco Services", "Remote", "Mid Level", ["Networking", "Security", "Troubleshooting", "Routing"], "Maintain and troubleshoot secure network infrastructure.", "Technology"),
    _role("Field Sales Executive", "PepsiCo", "Pan India", "Mid Level", ["Sales", "Field Work", "Negotiation", "Targets"], "Visit clients, sell products, and build local market coverage.", "Sales"),
    _role("UX Designer", "Figma Community Team", "Remote", "Mid Level", ["UI", "UX", "Prototyping", "Research"], "Design user interfaces, prototypes, and interaction flows.", "Design"),
    _role("Kotlin Developer", "Mobile Banking Team", "Bengaluru, India", "Mid Level", ["Kotlin", "Android", "REST APIs", "Git"], "Build Android apps with Kotlin, APIs, and best-practice architecture.", "Technology"),
    _role("Research Assistant", "University Lab", "Remote", "Entry to Mid", ["Research", "Documentation", "Analysis", "Reporting"], "Support academic research with experiments and literature review.", "Education"),
    _role("Warehouse Associate", "Amazon Fulfillment", "Delhi NCR, India", "Entry", ["Warehouse", "Inventory", "Safety", "Operations"], "Support picking, packing, inventory, and warehouse safety.", "Operations"),
]


def search_roles(query: str, page: int, page_size: int) -> Dict[str, object]:
    normalized = query.strip().lower()
    items = ROLE_LIBRARY

    if normalized:
        items = [
            role
            for role in ROLE_LIBRARY
            if normalized in " ".join(
                [
                    str(role["role_name"]),
                    str(role["company"]),
                    str(role["location"]),
                    str(role["level"]),
                    str(role["industry"]),
                    " ".join(role["tags"]),
                    str(role["summary"]),
                ]
            ).lower()
        ]

    total = len(items)
    start = max(page - 1, 0) * page_size
    end = start + page_size
    paged = items[start:end]

    return {
        "items": paged,
        "page": page,
        "page_size": page_size,
        "total": total,
        "total_pages": max((total + page_size - 1) // page_size, 1),
    }


def find_role(role_id: str) -> Dict[str, object] | None:
    for role in ROLE_LIBRARY:
        if role["id"] == role_id:
            return role
    return None
