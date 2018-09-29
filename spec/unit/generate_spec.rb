# frozen_string_literal: true

RSpec.describe TTY::Config, '#generate' do
  it "generate config content" do
    conf = {
      'int'   => 1,
      'false' => false,
      'str'   => 'hello',
      'array' => [1,2,3],
      'deep_array' =>  [
        {foo: 1},
        {bar: 2}
      ],
      'section' => {
        'value' => 1,
        'empty' => nil,
        'array' => [1,2,3]
      },
      "empty" => { },
      'nil'   => nil,
    }

    content = TTY::Config.generate(conf)

    expect(content).to eq <<-EOS
array = 1,2,3
false = false
int = 1
str = hello

[deep_array]
foo = 1
bar = 2

[section]
value = 1
array = 1,2,3
    EOS
  end

  it "generate config content with custom separator" do
    conf = {
      'str'   => 'hello',
      'array' => [1,2,3],
      'deep_array' =>  [
        {foo: 1},
        {bar: 2}
      ],
      'section' => {
        'value' => 1,
        'array' => [1,2,3]
      }
    }

    content = TTY::Config.generate(conf, separator: ':')

    expect(content).to eq <<-EOS
array : 1,2,3
str : hello

[deep_array]
foo : 1
bar : 2

[section]
value : 1
array : 1,2,3
    EOS
  end
end
