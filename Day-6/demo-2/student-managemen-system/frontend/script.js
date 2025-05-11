// API Base URL - UPDATED to match your specific server
const API_URL = 'http://44.246.204.147:3000/api/students'; // replace the IP with your ec2-IP

// DOM Elements
const studentForm = document.getElementById('student-form');
const studentList = document.getElementById('student-list');
const formTitle = document.getElementById('form-title');
const submitBtn = document.getElementById('submit-btn');
const cancelBtn = document.getElementById('cancel-btn');
const studentIdInput = document.getElementById('student-id');
const nameInput = document.getElementById('name');
const emailInput = document.getElementById('email');
const courseInput = document.getElementById('course');

// Get all students when page loads
document.addEventListener('DOMContentLoaded', fetchStudents);

// Form submit event
studentForm.addEventListener('submit', handleFormSubmit);

// Cancel button event
cancelBtn.addEventListener('click', resetForm);

// Fetch all students from API
async function fetchStudents() {
  try {
    const response = await fetch(API_URL);
    const students = await response.json();

    // Clear the student list
    studentList.innerHTML = '';

    // Add each student to the table
    students.forEach(student => {
      addStudentToTable(student);
    });
  } catch (error) {
    console.error('Error fetching students:', error);
    alert('Failed to load students. Please try again.');
  }
}

// Add a student to the table
function addStudentToTable(student) {
  const row = document.createElement('tr');

  row.innerHTML = `
    <td>${student.id}</td>
    <td>${student.name}</td>
    <td>${student.email}</td>
    <td>${student.course}</td>
    <td>
      <button class="edit-btn" data-id="${student.id}">Edit</button>
      <button class="delete-btn" data-id="${student.id}">Delete</button>
    </td>
  `;

  // Add event listeners to buttons
  const editBtn = row.querySelector('.edit-btn');
  const deleteBtn = row.querySelector('.delete-btn');

  editBtn.addEventListener('click', () => editStudent(student));
  deleteBtn.addEventListener('click', () => deleteStudent(student.id));

  studentList.appendChild(row);
}

// Handle form submission (create or update)
async function handleFormSubmit(event) {
  event.preventDefault();

  // Get form data
  const studentData = {
    name: nameInput.value,
    email: emailInput.value,
    course: courseInput.value
  };

  // Debug log
  console.log('Submitting data:', studentData);

  const id = studentIdInput.value;

  try {
    if (id) {
      // Update existing student
      console.log('Updating student with ID:', id);
      await updateStudent(id, studentData);
    } else {
      // Create new student
      console.log('Creating new student');
      await createStudent(studentData);
    }

    console.log('Operation successful');
    // Reset form and refresh student list
    resetForm();
    fetchStudents();
  } catch (error) {
    console.error('Error saving student:', error);
    alert('Failed to save student. Please try again. Error: ' + error.message);
  }
}

// Create a new student
async function createStudent(studentData) {
  try {
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(studentData)
    });

    if (!response.ok) {
      const errorData = await response.json();
      console.error('Server error:', errorData);
      throw new Error('Server returned ' + response.status);
    }

    return await response.json();
  } catch (error) {
    console.error('Network or parsing error:', error);
    throw error;
  }
}

// Update an existing student
async function updateStudent(id, studentData) {
  try {
    const response = await fetch(`${API_URL}/${id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(studentData)
    });

    if (!response.ok) {
      const errorData = await response.json();
      console.error('Server error:', errorData);
      throw new Error('Server returned ' + response.status);
    }

    return await response.json();
  } catch (error) {
    console.error('Network or parsing error:', error);
    throw error;
  }
}

// Delete a student
async function deleteStudent(id) {
  if (!confirm('Are you sure you want to delete this student?')) {
    return;
  }

  try {
    const response = await fetch(`${API_URL}/${id}`, {
      method: 'DELETE'
    });

    if (!response.ok) {
      const errorData = await response.json();
      console.error('Server error:', errorData);
      throw new Error('Server returned ' + response.status);
    }

    // Refresh student list
    fetchStudents();
  } catch (error) {
    console.error('Error deleting student:', error);
    alert('Failed to delete student. Please try again. Error: ' + error.message);
  }
}

// Fill form with student data for editing
function editStudent(student) {
  // Set form to edit mode
  formTitle.textContent = 'Edit Student';
  submitBtn.textContent = 'Update Student';
  cancelBtn.style.display = 'inline-block';

  // Fill form fields
  studentIdInput.value = student.id;
  nameInput.value = student.name;
  emailInput.value = student.email;
  courseInput.value = student.course;
}

// Reset form to add mode
function resetForm() {
  formTitle.textContent = 'Add New Student';
  submitBtn.textContent = 'Add Student';
  cancelBtn.style.display = 'none';

  studentForm.reset();
  studentIdInput.value = '';
}
