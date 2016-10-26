require_relative '../lib/iroha/builder/simple'

include Iroha::Builder::Simple

design = IDesign :design do
  IModule :m_top do
    ITable :tab_top do
      SubModuleTaskCall :task => Ref(:m_sub, :tab_sub, :task)
      IState            :st10
      st10.on {
        task.call
      }
    end
    IModule :m_sub do
      ITable :tab_sub do
        SubModuleTask   :task
        IState          :st20
        st20.on {
          task.entry
        }
      end
    end
  end
end

puts design.to_exp("")
