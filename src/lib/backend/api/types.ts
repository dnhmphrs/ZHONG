export type Profile = {
    id: string;
    role: 'patient' | 'clinician';
    name: string;
    email: string;
}

export type Cohort = {
    id: string;
    name: string;
    description: string;
    clinician_id: string;
    created_at: string;
}

export type Patient = Profile & {
    lastEntry?: string;
    completionRate?: number;
}

export type Entry = {
    id: string;
    diary_id: string;
    aspect_id: number;
    patient_id: string;
    entry_date: string;
    content_scale: number | null;
    content_text: string | null;
} 