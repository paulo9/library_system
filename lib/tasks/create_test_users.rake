namespace :users do
  desc "Create test users for development"
  task create_test_users: :environment do
    puts "Creating test users..."
    
    # Create librarian users
    librarian_users = [
      {
        email: "librarian@library.com",
        password: "password123",
        first_name: "Sarah",
        last_name: "Johnson",
        role: "librarian"
      },
      {
        email: "admin@library.com", 
        password: "password123",
        first_name: "Michael",
        last_name: "Brown",
        role: "librarian"
      }
    ]
    
    # Create member users
    member_users = [
      {
        email: "member1@library.com",
        password: "password123", 
        first_name: "John",
        last_name: "Smith",
        role: "member"
      },
      {
        email: "member2@library.com",
        password: "password123",
        first_name: "Emily", 
        last_name: "Davis",
        role: "member"
      },
      {
        email: "member3@library.com",
        password: "password123",
        first_name: "David",
        last_name: "Wilson",
        role: "member"
      }
    ]
    
    all_users = librarian_users + member_users
    
    all_users.each do |user_attrs|
      user = User.find_or_create_by(email: user_attrs[:email]) do |u|
        u.assign_attributes(user_attrs)
      end
      
      if user.persisted?
        puts "✓ #{user.role.titleize}: #{user.email} (#{user.full_name})"
      else
        puts "✗ Failed to create user: #{user_attrs[:email]} - #{user.errors.full_messages.join(', ')}"
      end
    end
    
    puts "\nTest users created successfully!"
    puts "\nLogin credentials:"
    puts "Librarians (can manage books):"
    librarian_users.each { |u| puts "  Email: #{u[:email]}, Password: #{u[:password]}" }
    puts "\nMembers (can only view books):"
    member_users.each { |u| puts "  Email: #{u[:email]}, Password: #{u[:password]}" }
  end
end
