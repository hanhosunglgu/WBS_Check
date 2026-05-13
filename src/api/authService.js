import axios from 'axios';

// 로그인 API 호출
export const login = async (username, password) => {
  const response = await axios.post('/api/auth/login', { username, password });
  return response.data;
};

// 로그아웃 API 호출
export const logout = async () => {
  const response = await axios.post('/api/auth/logout');
  return response.data;
};

// 회원가입 API 호출
export const register = async (username, password, email) => {
  const response = await axios.post('/api/auth/register', { username, password, email });
  return response.data;
};

// 사용자 정보 조회
export const getUser = async (id) => {
  const response = await axios.get(`/api/users/${id}`);
  return response.data;
};

// 사용자 정보 수정
export const updateUser = async (id, data) => {
  const response = await axios.put(`/api/users/${id}`, data);
  return response.data;
};
