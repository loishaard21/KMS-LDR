export const API_BASE_URL = "http://localhost:3000/api";

// Helper for fetch options
async function request(url: string, method = "GET", body?: any) {
  const headers: Record<string, string> = {
    "Content-Type": "application/json",
  };
  const config: RequestInit = {
    method,
    headers,
  };
  if (body) {
    config.body = JSON.stringify(body);
  }
  const res = await fetch(`${API_BASE_URL}/${url}`, config);
  if (!res.ok) {
    const errorData = await res.json().catch(() => ({}));
    throw new Error(errorData.message || `Request failed: ${res.statusText}`);
  }
  return res.json();
}

// 1. Auth
export async function apiLogin(body: any) {
  return request("auth/login", "POST", body);
}

// 2. Users (Operators)
export async function fetchUsers() {
  return request("users");
}
export async function createUser(data: any) {
  return request("users", "POST", data);
}
export async function updateUser(id: string, data: any) {
  return request(`users/${id}`, "PUT", data);
}
export async function deleteUser(id: string) {
  return request(`users/${id}`, "DELETE");
}

// 3. Articles
export async function fetchArticles() {
  return request("articles");
}
export async function createArticle(data: any) {
  return request("articles", "POST", data);
}
export async function updateArticle(id: string, data: any) {
  return request(`articles/${id}`, "PUT", data);
}
export async function deleteArticle(id: string) {
  return request(`articles/${id}`, "DELETE");
}

// 4. Seminars
export async function fetchSeminars() {
  return request("seminars");
}
export async function fetchSeminar(id: string) {
  return request(`seminars/${id}`);
}
export async function createSeminar(data: any) {
  return request("seminars", "POST", data);
}
export async function updateSeminar(id: string, data: any) {
  return request(`seminars/${id}`, "PUT", data);
}
export async function deleteSeminar(id: string) {
  return request(`seminars/${id}`, "DELETE");
}

// 5. Materials
export async function fetchMaterials() {
  return request("materials");
}
export async function createMaterial(data: any) {
  return request("materials", "POST", data);
}
export async function updateMaterial(id: string, data: any) {
  return request(`materials/${id}`, "PUT", data);
}
export async function deleteMaterial(id: string) {
  return request(`materials/${id}`, "DELETE");
}

// 6. Schedules
export async function fetchSchedules() {
  return request("schedules");
}
export async function createSchedule(data: any) {
  return request("schedules", "POST", data);
}
export async function updateSchedule(id: string, data: any) {
  return request(`schedules/${id}`, "PUT", data);
}
export async function deleteSchedule(id: string) {
  return request(`schedules/${id}`, "DELETE");
}

// 7. Participants
export async function fetchParticipants() {
  return request("participants");
}
export async function createParticipant(data: any) {
  return request("participants", "POST", data);
}
export async function updateParticipant(id: string, data: any) {
  return request(`participants/${id}`, "PUT", data);
}
export async function deleteParticipant(id: string) {
  return request(`participants/${id}`, "DELETE");
}

// 8. Announcements
export async function fetchAnnouncements() {
  return request("announcements");
}
export async function createAnnouncement(data: any) {
  return request("announcements", "POST", data);
}
export async function deleteAnnouncement(id: string) {
  return request(`announcements/${id}`, "DELETE");
}

// 9. Regulations
export async function fetchRegulations() {
  return request("regulations");
}
export async function createRegulation(data: any) {
  return request("regulations", "POST", data);
}
export async function updateRegulation(id: string, data: any) {
  return request(`regulations/${id}`, "PUT", data);
}
export async function deleteRegulation(id: string) {
  return request(`regulations/${id}`, "DELETE");
}

// 10. Evaluations
export async function fetchEvaluations() {
  return request("evaluations");
}
export async function createEvaluation(data: any) {
  return request("evaluations", "POST", data);
}
export async function updateEvaluation(id: string, data: any) {
  return request(`evaluations/${id}`, "PUT", data);
}
export async function deleteEvaluation(id: string) {
  return request(`evaluations/${id}`, "DELETE");
}

// 11. Galleries
export async function fetchGalleries() {
  return request("galleries");
}
export async function createGallery(data: any) {
  return request("galleries", "POST", data);
}
export async function updateGallery(id: string, data: any) {
  return request(`galleries/${id}`, "PUT", data);
}
export async function deleteGallery(id: string) {
  return request(`galleries/${id}`, "DELETE");
}

// 12. Guides (Panduan)
export async function fetchGuides() {
  return request("guides");
}
export async function createGuide(data: any) {
  return request("guides", "POST", data);
}
export async function updateGuide(id: string, data: any) {
  return request(`guides/${id}`, "PUT", data);
}
export async function deleteGuide(id: string) {
  return request(`guides/${id}`, "DELETE");
}
