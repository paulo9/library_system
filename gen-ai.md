# 🧠 Using Generative AI Tools to Build a RESTful API

## 📋 Project Overview

The goal of this task was to generate a RESTful API for a simple Task Management System using a Generative AI coding assistant (in this case, Cursor running GPT-4 or Claude 3.5 Sonnet).

### API Requirements

The API needed to support:

- **CRUD operations** for Tasks (title, description, status, due_date)
- **User association** - Each task associated with a User
- **JWT authentication** with Devise
- **Proper validations**, error handling, and Rails best practices
- **API versioning** (/api/v1/...)

## 💬 Prompt Used

The prompt was structured in JSON to provide maximum clarity, context, and control over the model's behavior.

```json
{
  "role": "developer",
  "task": "Generate a RESTful API for a task management system in Ruby on Rails.",
  "details": {
    "requirements": [
      "CRUD for Task (title, description, status, due_date)",
      "Each Task belongs_to User",
      "Add basic validations",
      "Use Devise with JWT for authentication",
      "Add API versioning (v1 namespace)",
      "Generate controllers, models, and routes"
    ],
    "style": {
      "idiomatic": true,
      "follow_rails_conventions": true,
      "include_error_handling": true
    },
    "output": {
      "format": "full_code_with_explanations",
      "language": "ruby"
    }
  }
}
```

## 🧩 Why Use JSON for Prompting

Using structured JSON prompts provides several advantages when working with large language models:

### Token Efficiency

JSON is compact and minimizes redundant natural language phrasing. Since each token (word/character chunk) counts toward the model's input limit, using structured keys reduces token usage and ensures more of the context fits in memory.

### Semantic Clarity

LLMs interpret structured inputs more deterministically. By explicitly defining keys like "requirements", "style", and "output", the model better understands the hierarchy of information and responds consistently.

### Reduced Ambiguity

A JSON schema forces precision. It prevents vague instructions such as "make it look nice," which can lead to inconsistent or verbose responses.

### Improved Parsing and Reproducibility

Structured prompts are easier to reuse, log, and compare across iterations when refining the AI's output.

In essence, using JSON helps the model focus on intent rather than interpreting free-form natural language, which leads to fewer misunderstandings and cleaner code generation.

## 🧱 Sample Output (Representative)

### Task Model

```ruby
# app/models/task.rb
class Task < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :status, inclusion: { in: %w[pending in_progress completed] }
end
```

### Tasks Controller

```ruby
# app/controllers/api/v1/tasks_controller.rb
module Api
  module V1
    class TasksController < ApplicationController
      before_action :authenticate_user!
      before_action :set_task, only: %i[show update destroy]

      def index
        render json: current_user.tasks
      end

      def show
        render json: @task
      end

      def create
        @task = current_user.tasks.new(task_params)
        if @task.save
          render json: @task, status: :created
        else
          render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @task.update(task_params)
          render json: @task
        else
          render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @task.destroy
        head :no_content
      end

      private

      def set_task
        @task = current_user.tasks.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Task not found' }, status: :not_found
      end

      def task_params
        params.require(:task).permit(:title, :description, :status, :due_date)
      end
    end
  end
end
```

## 🔍 Validation Process

### Migration and Model Checks

- Ensured `t.references :user, foreign_key: true` was included
- Confirmed correct column types (date for due_date)

### Authentication & Security

- Verified `before_action :authenticate_user!` and proper use of `current_user` scoping

### Error Handling

- Added `rescue ActiveRecord::RecordNotFound` and clear JSON responses

### Performance & Idiomatic Quality

- Confirmed adherence to Rails conventions: RESTful routes, strong parameters, and HTTP status codes

## ⚙️ Manual Refinements After AI Generation

- Refactored JSON responses using idiomatic `render json:` calls
- Added proper namespace `:api` versioning (api/v1/tasks)
- Included request specs for CRUD and JWT authentication
- Documented example curl requests in the README for testing

## 🧩 Edge Cases Considered

| Scenario            | Handling                                       |
| ------------------- | ---------------------------------------------- |
| Missing title       | `validates :title, presence: true`             |
| Invalid status      | Enum or inclusion validation                   |
| Unauthorized access | Scoped queries using `current_user.tasks.find` |
| Past due date       | Optional custom validation                     |
| Invalid JWT token   | 401 Unauthorized with JSON error               |

## 📈 Assessment of the AI Output

The AI assistant significantly accelerated boilerplate creation and routing setup. However, human validation remained essential to ensure:

- **Accurate database relationships** and migrations
- **Proper authentication** and authorization logic
- **Clean, idiomatic Rails** structure

By providing a structured, token-efficient JSON prompt, the model's reasoning stayed focused, producing cleaner, more maintainable code with minimal corrections required.
