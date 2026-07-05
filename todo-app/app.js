// Simple todo app with localStorage persistence
const STORAGE_KEY = 'todos_v1';

let todos = [];
let filter = 'all'; // all | active | completed

// DOM
const form = document.getElementById('todo-form');
const input = document.getElementById('todo-input');
const list = document.getElementById('todo-list');
const itemsLeft = document.getElementById('items-left');
const filters = document.querySelectorAll('.filter');
const clearCompletedBtn = document.getElementById('clear-completed');

function save() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(todos));
}

function load() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    todos = raw ? JSON.parse(raw) : [];
  } catch (e) {
    console.error('Failed to parse todos from localStorage', e);
    todos = [];
  }
}

function uid() {
  return Date.now().toString(36) + Math.random().toString(36).slice(2,8);
}

function addTodo(text) {
  const t = { id: uid(), text: text.trim(), completed: false, createdAt: Date.now() };
  todos.unshift(t);
  save();
  render();
}

function toggleTodo(id) {
  const t = todos.find(x => x.id === id);
  if (t) t.completed = !t.completed;
  save();
  render();
}

function deleteTodo(id) {
  todos = todos.filter(x => x.id !== id);
  save();
  render();
}

function updateTodoText(id, newText) {
  const t = todos.find(x => x.id === id);
  if (t) t.text = newText.trim();
  save();
  render();
}

function clearCompleted() {
  todos = todos.filter(x => !x.completed);
  save();
  render();
}

function filteredTodos() {
  if (filter === 'active') return todos.filter(t => !t.completed);
  if (filter === 'completed') return todos.filter(t => t.completed);
  return todos;
}

function render() {
  list.innerHTML = '';
  const items = filteredTodos();
  if (items.length === 0) {
    const empty = document.createElement('li');
    empty.className = 'todo-item';
    empty.textContent = 'No tasks';
    list.appendChild(empty);
  } else {
    for (const t of items) {
      const li = document.createElement('li');
      li.className = 'todo-item' + (t.completed ? ' completed' : '');
      li.dataset.id = t.id;

      const checkbox = document.createElement('input');
      checkbox.type = 'checkbox';
      checkbox.checked = t.completed;
      checkbox.addEventListener('change', () => toggleTodo(t.id));

      const title = document.createElement('div');
      title.className = 'title';
      title.textContent = t.text;
      title.title = 'Double-click to edit';
      title.tabIndex = 0;

      // edit on double click
      title.addEventListener('dblclick', () => startEditing(li, t));
      title.addEventListener('keydown', (e) => {
        if (e.key === 'Enter') startEditing(li, t);
      });

      const deleteBtn = document.createElement('button');
      deleteBtn.innerHTML = '✕';
      deleteBtn.title = 'Delete';
      deleteBtn.addEventListener('click', () => deleteTodo(t.id));

      li.appendChild(checkbox);
      li.appendChild(title);
      li.appendChild(deleteBtn);
      list.appendChild(li);
    }
  }

  const remaining = todos.filter(t => !t.completed).length;
  itemsLeft.textContent = `${remaining} item${remaining !== 1 ? 's' : ''} left`;
  // update filter buttons' active class
  filters.forEach(btn => btn.classList.toggle('active', btn.dataset.filter === filter));
}

// start inline editing
function startEditing(li, todo) {
  const title = li.querySelector('.title');
  const input = document.createElement('input');
  input.type = 'text';
  input.value = todo.text;
  input.className = 'edit-input';
  input.style.width = '100%';
  // replace title with input
  li.replaceChild(input, title);
  input.focus();
  input.setSelectionRange(input.value.length, input.value.length);

  function finish(saveEdit) {
    if (saveEdit) {
      const val = input.value.trim();
      if (val) updateTodoText(todo.id, val);
      else deleteTodo(todo.id);
    } else {
      render();
    }
  }

  input.addEventListener('keydown', (e) => {
    if (e.key === 'Enter') finish(true);
    else if (e.key === 'Escape') finish(false);
  });
  input.addEventListener('blur', () => finish(true));
}

// event handlers
form.addEventListener('submit', (e) => {
  e.preventDefault();
  const text = input.value.trim();
  if (text) {
    addTodo(text);
    input.value = '';
    input.focus();
  }
});

filters.forEach(btn => {
  btn.addEventListener('click', () => {
    filter = btn.dataset.filter;
    render();
  });
});

clearCompletedBtn.addEventListener('click', () => {
  clearCompleted();
});

// init
load();
render();
