require "application_system_test_case"

class RegistrationsTest < ApplicationSystemTestCase
  setup do
    @tournament = tournaments(:indoor)
    @group = groups(:morning)
    @tournament_class = tournament_classes(:rec_herren)
    @target_face = target_faces(:spot)
  end

  test "creates a registration" do
    assert_difference([ "Participant.count", "Registration.count" ], 1) do
      visit tournament_participants_path(@tournament, locale: :en)
      click_on "Register", match: :first

      fill_in "Given name:", with: "Foo"
      fill_in "Last name:", with: "Bar"
      fill_in "Club:", with: "FooClub"
      fill_in "Email address:", with: "foo@example.com"
      page.execute_script(<<~JS)
        const dob = document.getElementById("dob");
        dob.value = "2000-01-01";
        dob.dispatchEvent(new Event("input", { bubbles: true }));
      JS
      assert_selector "select#class option", text: "Recurve Herren"
      page.execute_script(<<~JS)
        const cls = document.getElementById("class");
        cls.value = "#{@tournament_class.id}";
        cls.dispatchEvent(new Event("input", { bubbles: true }));
        cls.dispatchEvent(new Event("change", { bubbles: true }));
      JS
      assert_selector "select#target_face option", text: "Spot"
      page.execute_script(<<~JS)
        const targetFace = document.getElementById("target_face");
        targetFace.value = "#{@target_face.id}";
        targetFace.dispatchEvent(new Event("input", { bubbles: true }));
        targetFace.dispatchEvent(new Event("change", { bubbles: true }));

        const group = document.getElementById("group");
        group.value = "#{@group.id}";
        group.dispatchEvent(new Event("input", { bubbles: true }));
        group.dispatchEvent(new Event("change", { bubbles: true }));
      JS
      assert_selector "select#group option:checked", text: "Vormittag"
      assert_selector "select#class option:checked", text: "Recurve Herren"
      assert_selector "select#target_face option:checked", text: "Spot"
      fill_in "Comment:", with: "Looking forward to it"

      assert_button "Submit", disabled: false
      click_on "Submit"
      assert_current_path tournament_participants_path(@tournament, locale: :en)
      assert_text "Foo Bar"
    end

    assert_text "Foo Bar"
    assert_text "Recurve Herren"
    assert_text "Spot"
    assert_text "FooClub"
    assert_text "Vormittag"

    registration = Registration.order(:created_at).last
    assert_equal "foo@example.com", registration.email
    assert_equal "Looking forward to it", registration.comment
  end

  test "creates a registration with multiple participants" do
    assert_difference("Participant.count", 2) do
      assert_difference("Registration.count", 1) do
        visit tournament_participants_path(@tournament, locale: :en)
        click_on "Register multiple"

        fill_in "Email address:", with: "team@example.com"
        fill_in "Club:", with: "TeamClub"
        fill_in "Comment:", with: "Registering two archers"

        fill_in "first_name_0", with: "Foo"
        fill_in "last_name_0", with: "Bar"
        page.execute_script(<<~JS)
          const dob = document.getElementById("dob_0");
          dob.value = "2000-01-01";
          dob.dispatchEvent(new Event("input", { bubbles: true }));
        JS
        assert_selector "select#class_0 option", text: "Recurve Herren"
        page.execute_script(<<~JS)
          const cls = document.getElementById("class_0");
          cls.value = "#{@tournament_class.id}";
          cls.dispatchEvent(new Event("input", { bubbles: true }));
          cls.dispatchEvent(new Event("change", { bubbles: true }));
        JS
        assert_selector "select#target_face_0 option", text: "Spot"
        page.execute_script(<<~JS)
          const targetFace = document.getElementById("target_face_0");
          targetFace.value = "#{@target_face.id}";
          targetFace.dispatchEvent(new Event("input", { bubbles: true }));
          targetFace.dispatchEvent(new Event("change", { bubbles: true }));

          const group = document.getElementById("group_0");
          group.value = "#{@group.id}";
          group.dispatchEvent(new Event("input", { bubbles: true }));
          group.dispatchEvent(new Event("change", { bubbles: true }));
        JS

        click_on "+"

        fill_in "first_name_1", with: "Baz"
        fill_in "last_name_1", with: "Qux"
        page.execute_script(<<~JS)
          const dob = document.getElementById("dob_1");
          dob.value = "2000-01-01";
          dob.dispatchEvent(new Event("input", { bubbles: true }));
        JS
        assert_selector "select#class_1 option", text: "Recurve Herren"
        page.execute_script(<<~JS)
          const cls = document.getElementById("class_1");
          cls.value = "#{@tournament_class.id}";
          cls.dispatchEvent(new Event("input", { bubbles: true }));
          cls.dispatchEvent(new Event("change", { bubbles: true }));
        JS
        assert_selector "select#target_face_1 option", text: "Spot"
        page.execute_script(<<~JS)
          const targetFace = document.getElementById("target_face_1");
          targetFace.value = "#{@target_face.id}";
          targetFace.dispatchEvent(new Event("input", { bubbles: true }));
          targetFace.dispatchEvent(new Event("change", { bubbles: true }));

          const group = document.getElementById("group_1");
          group.value = "#{@group.id}";
          group.dispatchEvent(new Event("input", { bubbles: true }));
          group.dispatchEvent(new Event("change", { bubbles: true }));
        JS

        assert_button "Submit", disabled: false
        click_on "Submit"
        assert_current_path tournament_participants_path(@tournament, locale: :en)
        assert_text "Foo Bar"
        assert_text "Baz Qux"
      end
    end

    assert_text "Foo Bar"
    assert_text "Baz Qux"
    assert_text "Recurve Herren"
    assert_text "Spot"
    assert_text "TeamClub"
    assert_text "Vormittag"

    registration = Registration.order(:created_at).last
    assert_equal "team@example.com", registration.email
    assert_equal "Registering two archers", registration.comment
    assert_equal [ "Baz Qux", "Foo Bar" ], registration.participants.map { |participant| "#{participant.first_name} #{participant.last_name}" }.sort
  end
end
