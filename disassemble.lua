--[[ 
                                             Copyright 2024 - kkeyy

 All rights reserved. This Lua code is the intellectual property of kkeyy and is protected by copyright laws and international treaties. 
 Unauthorized use, reproduction, or distribution of this code, in whole or in part, without the prior written consent of kkeyy, is strictly prohibited.
 This code is provided "as is" without any warranty, express or implied, including but not limited to the implied warranties of merchantability and fitness for a particular purpose. 
 kkeyy shall not be liable for any direct, indirect, incidental, special, exemplary, or consequential damages (including, but not limited to, procurement of substitute goods or services; loss of use, data, or profits; or business interruption) however caused and on any theory of liability, whether in contract, strict liability, or tort (including negligence or otherwise) arising in any way out of the use of this code, even if advised of the possibility of such damage.
 For inquiries regarding licensing, customization, or any other use of this code, please contact kkeyy at admin@kkeyy.lol.


]]--

local format, typev, string, concat = string.format, type, tostring, table.concat

local function Disassemble(chunk, id, opCodes) 
    local id = id or 0
    local Instructions = chunk.code
    local Constants = chunk.const
    local out = format("Proto[%d]\n> #Stack: %d\n> #Params: %d\n> #Name: \"%s\"\n\nConstants[%d]\n", id, chunk.maxstacksize, chunk.numparams, chunk.name or "undefined", chunk.sizek - 1)

    for i,v in pairs(Constants) do
        out = out .. format("> [%d] (%s) \"%s\"\n", i - 1, typev(v), string(v))
    end

    out = out .. format("\nInstructions[%d]\n", chunk.sizecode - 1)

    for i,v in pairs(Instructions) do
        local Opcode = opCodes[v.Opcode + 1] or string(v.Opcode)
        local Registers = v.Reg
        local Code = v.Code
        local B = Registers[2] + 1
        local Deduct = ""

        if Opcode == "LOP_GETIMPORT" then
            if Constants[B] then
                Deduct = format(" / R[2] = %s (%s)", string(Constants[B]), Constants[B - 1])
            else
                Deduct = format(" / R[2] = Env[\"%s\"]", Constants[B - 1])
            end;
        elseif Opcode == "LOP_LOADK" then
            Deduct = format(" / R[2] = \"%s\"", string(Constants[B]))
        end

        out = out .. format("> [%d->%d] %s { %s }%s\n", i - 1, Code, Opcode, concat(Registers, ", "), Deduct)
    end

    for i,v in pairs(chunk.p) do
        out = out .. "\n" .. Disassemble(v, i)
    end

    return out
end

return Disassemble
